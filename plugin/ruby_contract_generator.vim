
function! CreateRubyContractTest()
  " line number where the private keyword is
  let l:private_start_line = match(readfile(expand("%")), "private")
  let l:filepath = expand("%")
  let l:file = readfile(expand("%:p"))
  let l:class_line = matchstr(readfile(expand("%")), 'class \zs\(.*\)\ze\1')

  " CamelCased class
  let l:class_name = matchstr(class_line, 'class \zs\(.*\)\ze')

  " CamelCase to snake_case
  let l:class_name_snake = substitute(l:class_name, '\(\<\u\l\+\|\l\+\)\(\u\)', '\l\1_\l\2', '')

  " if the class is just one word, it won't make it to lower case. We do it
  " manually here
  let l:class_name_snake = tolower(l:class_name_snake)

  let l:code = ''

  for line in l:file
    let l:current_method_line = matchstr(line, "def.*")
    let l:current_line = match(l:file, line)

    if l:current_line >= l:private_start_line
      break
    endif

    if l:current_method_line >= 0

      let l:method = l:current_method_line
      let l:method = substitute(l:method, '\s*def ', '', '')
      " name of the method itself
      let l:method = substitute(l:method, '(.*', '', '')

      " constructor shouldn't be part of the contract
      if match(l:method, "initialize") >= 0
        continue
      endif

      " no support for class methods
      if match(l:method, "self\.") >= 0
        continue
      endif

      if empty(l:method)
        continue
      end

      let l:code .= "\n"
      let l:code .= '  it "responds to ' . l:method . '" do'
      let l:code .= "\n"
      let l:code .= '    subject.should respond_to(:' . l:method . ')'
      let l:code .= "\n"
      let l:code .= '  end'
      let l:code .= "\n"
    endif
  endfor

  let l:contract_file_path = CurrentContractFilePath("ruby", l:filepath)
  let l:contract_file_content = readfile(l:contract_file_path)

  " Generates the contract test code
  if !empty(l:code)
    let l:human_class_name = substitute(l:class_name_snake, '_', ' ', '')

    let l:class_path_without_lib = substitute(l:filepath, '^lib/', '', '')
    let l:class_path_without_lib = substitute(l:class_path_without_lib, '\.rb$', '', '')

    let l:header = ''
    let l:header .= 'require "' . l:class_path_without_lib . '"'
    let l:header .= "\n"
    let l:header .= "\n"

    let l:current_contract_title = matchstr(l:contract_file_content, 'shared_examples')

    if empty(l:current_contract_title)
      let l:header .= 'shared_examples_for "a ' . l:human_class_name . '" do'
    else
      let l:header .= l:current_contract_title
    endif

    let l:header .= "\n"

    let l:current_subject_class = matchstr(l:contract_file_content, 'subject')

    if empty(l:current_subject_class)
      let l:header .= '  subject { ' . l:class_name . '.new }'
    else
      let l:header .= l:current_subject_class
    endif

    let l:code = l:header . "\n" . l:code
    let l:code .= "end"
  endif

  execute ":split"
  execute ":wincmd j"
  execute ":e " . l:contract_file_path

  " Cleans the current file
  execute ":silent normal ggVGd\<Esc>"

  " Populates it with the generated code
  execute ":silent normal cc" . l:code . "\<Esc>"
  execute ":silent normal ggVG==\<Esc>"

  " Saves the current file
  execute ":w"
  execute ":wincmd k"
endfunction

function! IsRubyClass()
  return match(expand("%"), "class") >= 0
endfunction

function! CurrentContractFilePath(project, file_name)
  let l:contract_dir = ''
  let l:contract_file_dir = ''
  let l:contract_file_name = ''
  let l:contract_full_path = ''

  if matchstr(a:project, 'ruby') >= 0
    let l:contract_file_name = substitute(a:file_name, '.rb$', '_contract.rb', '')

    if isdirectory('spec/contracts')
      let l:contract_dir = 'spec/contracts/'
    elseif isdirectory('spec/support/contracts')
      let l:contract_dir = 'spec/support/contracts/'
    else
      let l:contract_dir = 'spec/contracts/'
    endif

    let l:contract_full_path = l:contract_dir . l:contract_file_name
    let l:contract_file_dir = matchstr(l:contract_full_path, '.*/')

    if !isdirectory(l:contract_file_dir)
      exec ':!mkdir -p ' . l:contract_file_dir
    endif


    if !filereadable(l:contract_full_path)
      " Creates the contract test file file
      :silent "!touch " . l:contract_full_path
    endif
  endif

  return l:contract_full_path
endfunction

function! CreateContractTest()
  if IsRubyClass() >= 0
    call CreateRubyContractTest()
  endif
endfunction

command! AContract call CreateContractTest()
