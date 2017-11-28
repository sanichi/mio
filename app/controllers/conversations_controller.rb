class ConversationsController < ApplicationController
  authorize_resource
  before_action :find_conversation, only: [:show, :edit, :update, :destroy]

  def index
    @conversations = Conversation.search(params, conversations_path)
  end

  def new
    @conversation = Conversation.new
  end

  def show
    if @conversation
      @next = Conversation.where("id > #{@conversation.id}").first
      @prev = Conversation.where("id < #{@conversation.id}").last
    end
  end

  def create
    @conversation = Conversation.new(strong_params)
    if @conversation.save
      redirect_to @conversation
    else
      render "new"
    end
  end

  def update
    if @conversation.update(strong_params)
      redirect_to @conversation
    else
      render action: "edit"
    end
  end

  def destroy
    @conversation.destroy
    redirect_to conversations_path
  end

  private

  def find_conversation
    @conversation = Conversation.find(params[:id])
  end

  def strong_params
    params.require(:conversation).permit(:audio, :story, :title)
  end
end
