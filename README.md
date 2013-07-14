# autocoder.vim

Creating appropriate classes in a Rails project improves your project. However,
the process of creating them and their RSpec tests is
annoying and painful (specially for someone lazy like me).

So I wrote this plugin.

## How to

Type `:AC`. Vim will ask you what's the path of the class you want to create:

    Type the path (e.g store/cart/item):

If you type `store/special_cart`, it will generate the following two files:

* `lib/store/special_cart.rb`

```ruby
module Store
  class SpecialCart
    def initialize(options)
      @options = options
    end

    private

    attr_reader :options
  end
end
```

* `spec/lib/store/special_cart_spec.rb`

```ruby
require "store/special_cart"

describe Store::SpecialCart do
  describe "#some_method" do
    it "returns true" do

    end
  end
end
```

### Known issues

* it only works for files in the lib dir
* it only works with RSpec
* if the file already exists, it'll add the boilerplate code anyway
* the code is messy, but it solves my problems

Please, send patches to fix these problems.

### License

MIT. Do what you want with it, but please consider contributing back :)
