compile_eex
================================

*mix task for compiling eex templates*


Quick start
-------------------------

Add the :eex to the compilers in mix.exs
```elixir

def project do
  [ app: :your_app,
    version: "0.0.1",
    deps: deps,
    compilers: [:elixir, :app, :eex]]
end

```

by default, the html files in the templates directory will get compiled.

e.g. when there is a ``` templates/hello.html ``` file, it will get compiled to Templates.Hello when  ``` mix compile ``` is executed

to render a string, call the render function.

```
Hello <%= @name =>
```
```elixir 
Templates.Hello name: "Markus" 
```
renders "Hello Markus"

TODO
-------------------------
- Recompile only when the template has changed
- Add functions for escaping output

License
-------------------------
Copyright (c) 2013, Markus Ecker

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



