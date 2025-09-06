module Wk
  class GroupsController < ApplicationController
    authorize_resource
    before_action :find_group, only: [:show, :edit, :update, :destroy]

    def index
      remember_last_search(wk_groups_path)
      @groups = Wk::Group.search(params, wk_groups_path, per_page: 15, locale: :jp)
    end

    def new
      @group = Wk::Group.new
    end

    def create
      @group = Group.new(strong_params)
      if @group.save
        redirect_to wk_groups_path
      else
        failure @group
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @group.update(strong_params)
        redirect_to wk_groups_path
      else
        failure @group
        render :edit, status: :unprocessable_entity
      end
    end

    def show
    end

    def destroy
      @group.destroy
      redirect_to wk_groups_path
    end

    private

    def find_group
      @group = Wk::Group.find(params[:id])
    end

    def strong_params
      params.require(:wk_group).permit(:category, :vocab_list, :notes)
    end
  end
end
