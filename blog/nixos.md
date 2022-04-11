I'd like to come up with some NixOS recipes for different box roles:

* dev - for human users. Includes editors and IDEs.  Prioritizes
        convenience and openness at the expense of strictness
* build - for machine users. Includes expansive sets of build tools, like
          gcc, make, clang, llvm, rust, ruby, python, java, etc.
	  No dev tools like editors and IDEs.
* app   - for machine users. Execution and runtime environment.
          Strict and minimal.  No build tools or dev tools.

I'm mostly playing with dev environments but ultimately looking to cook up
build and app environments.

For dev environments: https://github.com/rickhull/hello-nix
