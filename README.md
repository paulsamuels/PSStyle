The basic idea for this project is that you choose some structure for laying out the metaData about the things you want to style. At a later time you will be asked to provide an asset using this metaData.

##Installation and Use

Just include `PSStyleManager.*` and `PSStyleResolver.*`. Then implement your logic in subclasses of these two.

- A subclass of `PSStyleManager` - is where you declare the domain specific names of the assets you want to provide.
- Multiple subclasses of `PSStyleResolver` - is where you define the logic to provide assets when asked, you can provide your own basic caching behaviour and will be told when to purge your cache.

##Example application

The example application allows you to use sliders to change the values in a plist. When you select "Change Background" or "Change Button image" these values are read back in and the UI updated. This demonstrates how this could be used to allow some kind of theming.

##A full example

If you wanted to use `PSStyleManager` to look after your apps colours it would look something like this.

###1. Create your subclass of `PSStyleManager`.

In this case we have added singleton access and defined that we intend for there to be a method called `backgroundColor` available.

In `MyStyle.h`

    #import "PSStyleManager.h"

    @interface MyStyle : PSStyleManager

    + (id)sharedInstance;

    @property (nonatomic, strong, readonly) UIColor *backgroundColor;

    @end
    
In the implementation this would look like:

`MyStyle.m`

    #import "MyStyle.h"
    #import "MyColorResolver.h"
    
    @implementation MyStyle
    
    @dynamic backgroundColor; // This needs to be declared as dynamic
    
    + (id)sharedInstance;
    {
      static id instance = nil;

      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
      });

      return instance;
    }

    - (id)init;
    {
      self = [super init];
      if (self) {
        [self registerStyleResolverClass:[MyColorResolver class]];
      }
      return self;
    }
    
    @end
    
###2. Decide on the format of your plist

The styling meta data is configured from a plist of your design. The requirement is that the root object is a dictionary that contains a key with the same name as each of the `@dynamic` properties you declare. What this key points to is the data you will be handed to work with.

To keep things simple in this example we are just going to store the selector name of a colour which is available as a convenience method on `UIColor`

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>darkBackgroundColor</key>
        <string>redColor</string>
      </dict>
    </plist>
    
###3. Implement the resolver that can handle the meta data

As this example is deliberately simple, just using convenience methods on `UIColor`, the implementation for the resolver can also be pretty trivial. The resolver is the class that was registered in `PSStyleManager`'s init method

In `MyColorResolver.h`

    #import "PSStyleResolver.h"

    @interface MyColorResolver : PSStyleResolver

    @end
    
Then in `MyColorResolver.m`

    @implementation PSStyleColorResolver

    + (BOOL)canHandleStyleSelector:(SEL)sel;
    {
      return [NSStringFromSelector(sel) hasSuffix:@"Color"];
    }

    - (id)styleAssetWithKey:(NSString *)key metaData:(id)metaData;
    {
      SEL sel = NSSelectorFromString(metaData);
      
      UIColor *color = [UIColor performSelector:sel];

      if (!color) {
        [NSException raise:NSInternalInconsistencyException format:@"No color found for %@", key];
      }

      return color;
    }
    
    @end
    
In `+[MyColorResolver canHandleStyleSelector:]` we declare that this resolver will claim to handle any selector with the suffix `Color`. The `@dynamic` property we declared was `backgroundColor` so this resolver should be called.
    
In `styleAssetWithKey:metaData:` we are handed the metadata. In the case of calling `-[MyStyle backgroundColor]` we would receive the string `redColor` as defined in our plist. We then call this method on `UIColor` and return the result.

This is the simplest use case and provides the flexibility to externally configure an apps colours, albeit the nasty convenience method colours. Check the resolvers in the example project for more complex things involving caching, image lookup and image generation.