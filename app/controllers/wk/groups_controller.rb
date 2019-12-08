module Wk
  class GroupsController < ApplicationController
    authorize_resource
    before_action :find_group, only: [:edit, :update, :destroy]

    def index
      @groups = Wk::Group.search(params, wk_groups_path, per_page: 20)
    end

    def new
      @group = Wk::Group.new
    end

    def create
      @group = Group.new(strong_params)
      if @group.save
        redirect_to wk_groups_path
      else
        render :new
      end
    end

    def update
      if @group.update(strong_params)
        redirect_to wk_groups_path
      else
        render :edit
      end
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
      params.require(:wk_group).permit(:category, :vocab_list)
    end
  end
end
