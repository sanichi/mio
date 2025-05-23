module Wk
  class ExamplesController < ApplicationController
    authorize_resource
    before_action :find_example, only: [:edit, :update, :destroy]
    before_action :convert_day, only: [:create, :update]

    def index
      remember_last_search(wk_examples_path)
      @examples = Wk::Example.search(params, wk_examples_path, per_page: 10, locale: :jp)
    end

    def memorable
      @examples = Wk::Example.memorable(params, memorable_wk_examples_path, per_page: 10, locale: :jp)
    end

    def new
      @example = Wk::Example.new
      @return_page = store_return_page("examples", params[:return_page])
    end

    def edit
      @return_page = store_return_page("examples", params[:return_page])
    end

    def create
      @example = Example.new(strong_params)
      if @example.save
        redirect_to redirect_page
      else
        failure @example
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @example.update(strong_params)
        redirect_to redirect_page
      else
        failure @example
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @example.destroy
      redirect_to redirect_page
    end

    private

    def find_example
      @example = Wk::Example.find(params[:id])
    end

    def strong_params
      params.require(:wk_example).permit(:english, :japanese, :day)
    end

    def redirect_page
      retrieve_return_page("examples") || wk_examples_path
    end

    def convert_day
      day = params[:wk_example][:day]
      if day.blank?
        day = ""
      else
        begin
          day = Date.parse(day).to_fs(:db)
        rescue Date::Error
          day = Date.today.to_fs(:db)
        end
      end
      params[:wk_example][:day] = day
    end
  end
end
