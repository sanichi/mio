namespace :elm do
  desc "make the Elm JS file for Todos"
  task :todo do
    Dir.chdir("app/views/todos") do
      system("elm-make Main.elm --output _elm_todo.js")
    end
  end
end
