function! Strip(input_string)
  return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

" Generates the code for a given class
function! RailsCoderClassFileString(...)
  let l:class_names = a:1
  let l:code = ""

  let current_index = 0
  for i in l:class_names
    let l:class_name = substitute(Strip(i), '\%(^\|_\)\(.\)', '\u\1', 'g')

    if current_index != (len(l:class_names)-1)
      let l:code_namespace = "module"
    else
      let l:code_namespace = "class"
    endif
    let l:code = l:code . l:code_namespace . " " . l:class_name . "\n"

    let current_index += 1
  endfor

  let l:code = l:code . "def initialize(var)\n"
  let l:code = l:code . "@var = var\n"
  let l:code = l:code . "end\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "def method\n"
  let l:code = l:code . "puts @var\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "end"

  for i in l:class_names
    let l:code = l:code . "\nend"
  endfor

  return l:code
endfunction

" Generates the code for a given class
function! RailsCoderSpecFileString(...)
  let l:class_names = a:1
  let l:camel_cased_class_names = []

  for i in l:class_names
    let l:tmp = substitute(Strip(i), '\%(^\|_\)\(.\)', '\u\1', 'g')
    call add(l:camel_cased_class_names, l:tmp)
    echo l:camel_cased_class_names
  endfor

  let l:code = "require \"" . join(l:class_names, "/") . "\"\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "RSpec.describe " . join(l:camel_cased_class_names, "::") . " do\n"
  let l:code = l:code . "let(:item) { instance_double() }\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "subject { described_class.new(item) }\n"
  let l:code = l:code . "\n"
  let l:code = l:code . "describe \"#method\" do\n"
  let l:code = l:code . "it \"returns true\" do\n"
  let l:code = l:code . "subject.method\n"
  let l:code = l:code . "\nend"
  let l:code = l:code . "\nend"
  let l:code = l:code . "\nend"

  return l:code
endfunction

function! RailsCoderCreateClassFile()
  let l:class_name    = input('Type the path (e.g store/cart/item): ')
  let l:current_dir   = getcwd()
  let current_index = 0

  let l:class_names = split(class_name, "/")

  " CREATES THE PRODUCTION CODE

  " We're only creating these classes inside lib/
  exec ":cd ./lib"

  " Iterates over each namespace. If store/cart/item was entered, iterates
  " on store, cart and item, creating the subdirectories recursively if they
  " don't already exist.
  for i in l:class_names
    let l:filename = Strip(tolower(i))

    " If the current name is supposed to be a directory (e.g cart in
    " store/cart/item is supposed to be a file.
    if current_index != (len(l:class_names)-1)
      " creates directories recursively
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename

    " If the current name is supposed to be a file (e.g item is supposed
    " to be a file in store/cart/item)
    else
      " Creates the class file
      execute ":silent !touch " . l:filename . ".rb"
      " Opens it
      execute ":silent e " . l:filename . ".rb"
      " Populates it with the boilerplate code
      let l:class_code = RailsCoderClassFileString(l:class_names)
      execute ":silent normal cc" . l:class_code . "\<Esc>"
      " Saves the current file
      execute ":w"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir

  " CREATES THE RSPEC CODE

  " We're only creating these classes inside spec/lib/
  if isdirectory("spec/lib")
    exec ":cd ./spec/lib"
  else
    exec ":cd ./spec"
  endif

  " Iterates over each namespace. If store/cart/item was entered, iterates
  " on store, cart and item, creating the subdirectories recursively if they
  " don't already exist.
  let current_index = 0
  for i in l:class_names
    let l:filename = Strip(tolower(i))

    " If the current name is supposed to be a directory (e.g cart in
    " store/cart/item is supposed to be a file.
    if current_index != (len(l:class_names)-1)
      " creates directories recursively
      if !isdirectory(filename)
        exec ":!mkdir " . l:filename
      endif
      exec ":cd ./"   . l:filename

    " If the current name is supposed to be a file (e.g item is supposed
    " to be a file in store/cart/item)
    else
      " Creates the class file
      execute ":silent !touch " . l:filename . "_spec.rb"
      " Opens it in a horizontal split
      execute ":vsplit"
      execute ":wincmd l"
      execute ":e " . l:filename . "_spec.rb"

      " Populates it with the boilerplate code
      let l:class_code = RailsCoderSpecFileString(l:class_names)
      execute ":silent normal cc" . l:class_code . "\<Esc>"
      " Saves the current file
      execute ":w"
      execute ":wincmd h"
    endif
    let current_index += 1
  endfor

  exec ":cd " . l:current_dir
  execute ":redraw!"
endfunction

command! AC call RailsCoderCreateClassFile()
