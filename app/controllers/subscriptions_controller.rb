class SubscriptionsController < ApplicationController
  authorize_resource
  before_action :find_subscription, only: [:show, :edit, :update, :destroy]

  def index
    @subscriptions = Subscription.search(params)
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(strong_params)
    if @subscription.save
      redirect_to @subscription
    else
      failure @subscription
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @subscription.update(strong_params)
      redirect_to @subscription
    else
      failure @subscription
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @subscription.destroy
    redirect_to subscriptions_path
  end

  private

  def find_subscription
    @subscription = Subscription.find(params[:id])
  end

  def strong_params
    params.require(:subscription).permit(:active, :amount, :frequency, :payee, :source)
  end
end
