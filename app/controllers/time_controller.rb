class TimeController < ApplicationController
    def update_movie
        update = MovieProgress.where(user_id: params[:user_id], movie_id: params[:movie_id]).first
        if update.nil?
            update = MovieProgress.new
            update.movie_id = params[:movie_id]
            update.user_id = params[:user_id]
            update.time = params[:time]
            update.save
        else
            if params[:complete].present?
                update.destroy
            elsif params[:time].present?
                update.time = params[:time].to_i
                update.save
            end
        end
    end

    def mark_movie_complete
        update = MovieProgress.where(user_id: params[:user_id], movie_id: params[:movie_id]).first
        unless update.nil?
            update.destroy
        end
    end

    def update_show
        show_update = ShowProgress.where(show_id: params[:show_id], user_id: current_user.id).first

        if show_update.nil?
            show_update = ShowProgress.new
            show_update.show_id = params[:show_id]
            show_update.user_id = current_user.id
            show_update.episode_number = params[:episode_number]
            show_update.save

            episode_update = EpisodeProgress.new
            episode_update.time = params[:time]
            episode_update.show_progress_id = show_update.id
            episode_update.episode_id = params[:episode_id]
            episode_update.save
        else
            show_update.episode_number = params[:episode_number]
            show_update.save

            episode_update = EpisodeProgress.where(episode_id: params[:episode_id], show_progress_id: show_update.id).first

            unless episode_update.nil?
                episode_update.time = params[:time]
                episode_update.save
            else
                episode_update = EpisodeProgress.new
                episode_update.time = params[:time]
                episode_update.show_progress_id = show_update.id
                episode_update.episode_id = params[:episode_id]
                episode_update.save
            end
        end
    end

    def mark_episode_complete
        show_update = ShowProgress.where(show_id: params[:show_id], user_id: current_user.id, episode_number: params[:episode_number]).first
        episode_update = EpisodeProgress.where(episode_id: params[:episode_id], show_progress_id: show_update.id).first

        unless episode_update.nil?
            episode_update.destroy
        end
    end

    def mark_show_complete
        show_update = ShowProgress.where(show_id: params[:show_id], user_id: current_user.id).first

        unless show_update.nil?
            episode_updates = EpisodeProgress.where(show_progress_id: show_update.id)
            episode_updates.destroy_all
            show_update.destroy
        end
    end
end
