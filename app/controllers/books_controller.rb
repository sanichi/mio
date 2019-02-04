class BooksController < ApplicationController
  authorize_resource
  before_action :find_book, only: [ :show, :edit, :update, :destroy]

  def index
    @books = Book.search(params, books_path, per_page: 20)
  end

  def new
    @book = Book.new
    @book.medium = "book" # default because most are books
  end

  def create
    @book = Book.new(strong_params)
    if @book.save
      redirect_to @book
    else
      render "new"
    end
  end

  def update
    if @book.update(strong_params)
      redirect_to @book
    else
      render action: "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path
  end

  private

  def find_book
    @book = Book.find(params[:id])
  end

  def strong_params
    params.require(:book).permit(:author, :available, :borrower, :category, :medium, :note, :title, :year)
  end
end
