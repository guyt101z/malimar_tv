class VodMigrationsController < ApplicationController
    def start_upload

        if params[:existing] == 'true'
            @grid = Grid.find(params[:grid_id])
            @grid.file = params[:file]
            if @grid.save
                Resque.enqueue(Uploader, @grid.id)
                flash[:notice] = "File uploaded"
                redirect_to '/admins'
            else
                flash[:notice] = 'Error occurred saving migration, please try again'
                redirect_to '/admins'
            end
        else
            @grid = Grid.new
            @grid.name = params[:name]
            @grid.class_type = params[:class_type]
            if params[:grid_id].present?
                @grid.grid_id = params[:grid_id]
            end
            @grid.weight = params[:weight].to_i
            @grid.adult = params[:adult]
            @grid.home_page = params[:home_page]
            @grid.title_bar = params[:menu]
            @grid.sort = params[:sort]
            @grid.free = params[:free]
            @grid.file = params[:file]


            if @grid.save
                Resque.enqueue(Uploader, @grid.id)
                redirect_to '/admins'
            else
                flash[:error] = 'Error occurred saving migration, please try again'
                redirect_to '/admins'
            end
        end
    end
end
