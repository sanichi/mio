class BooksController < ApplicationController
  authorize_resource
  before_action :find_book, only: [:show]

  def index
    @books = Book.search(params, books_path, per_page: 20)
  end

  private

  def find_book
    @book = Book.find(params[:id])
  end
end
