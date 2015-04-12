class CommentsController < ApplicationController
  authorize_resource
  before_action :find_commentable, only: [:new]
  before_action :find_comment, only: [:edit, :update, :destroy]

  def new
    @comment = @commentable.comments.new(date: Date.today)
  end

  def create
    @comment = Comment.new(strong_params(true))
    if @comment.save
      redirect_to @comment.commentable
    else
      render "new"
    end
  end

  def update
    if @comment.update(strong_params)
      redirect_to @comment.commentable
    else
      render "edit"
    end
  end

  def destroy
    @comment.destroy
    redirect_to @comment.commentable
  end

  private

  def find_commentable
    klass = [Fund].detect{ |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def find_comment
    @comment = Comment.find(params[:id])
    @commentable = @comment.commentable
  end

  def strong_params(new_record=false)
    list = %i{date source text}
    list.concat %i{commentable_type commentable_id} if new_record
    params.require(:comment).permit(*list)
  end
end
