# Thinking about Ruby Refinements

## Rationale

Refinements exist in the Ruby programming language, introduced in Ruby 2.4,
in order to limit the scope of so-called "monkey patching", where user-defined
and even core classes or those in stdlib may be "opened up" and redefined.
This ability is very useful and convenient in limited scenarios, but when
code is intended to be reused, monkey patches tend to introduce unpredictable
conflicts.

The entire goal of Refinements is to able to say something like

```ruby
# above the 'using' statement, we have no refinements available

using MyRefinements

# from here until the bottom of the file, whatever refinements
# are in the MyRefinements module are activated
```

Thus, the use of any refinements is restricted to files which declare
they are `using` such refinements.  In this way, different parts of a large
codebase (or one that calls into many libraries) may use Refinements to
monkey-patch existing classes without requiring other files to expect or
respect the refined behavior.

## Example

I'd love to able to call the method `foo` on any String.  I expect `String#foo`
to always return the symbol `:bar`.

refinements.rb:

```ruby
module MyRefinements
  refine String do
    def foo *args
      :bar
    end
  end
end
```

elsewhere_codebase.rb:

```ruby
'asdf'.foo #=> NoMethodError

require 'refinements'
'asdf'.foo #=> NoMethodError

using MyRefinements
'asdf'.foo #=> :bar
```
