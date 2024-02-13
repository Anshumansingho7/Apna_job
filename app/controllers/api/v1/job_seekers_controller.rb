class Api::V1::JobSeekersController < ApplicationController


    before_action :set_seeker, only: [:show, :update]

    def searchindex
        @parameter = params[:search].downcase
        column_name = params[:column_name]
        if column_name == nil
            job_seeker = JobSeeker.search(@parameter)
        else
            if JobSeeker.has_attribute?("#{column_name}")
                job_seeker = JobSeeker.where("lower(#{column_name}) LIKE ?","#{@parameter}%")
            end
        end
        render json: {
            job_seeker: job_seeker
        },status: 200
    end

    def shortingindex
        asds = params[:asds]
        column_name = params[:column_name]
        if JobSeeker.has_attribute?("#{column_name}")
            job_seeker = JobSeeker.all.order("#{column_name} #{asds} ")
        end
        render json: {
            job_seeker: job_seeker
        },status: 200
    end

    
    def show 
        render json: @job_seeker
    end

    def create 
        if current_user.role === "job_seeker"
            job_seeker = current_user.build_job_seeker(job_seeker_params)
            if job_seeker.save
                notification = Notification.new(
                    user_id: current_user.id,
                    discription: "your detail has been succesfully saved"
                )
                notification.save
                render json: job_seeker, status: :ok
            else
                render json: {
                    data: job_seeker.errors.full_messages,
                    status: 'failed'
                },status: :unprocessable_entity
            end
        else
            render json: {
                message: "You cannot create company your role is recuiter"
            },status: :unprocessable_entity
        end
    end


    def update
        if @job_seeker.update(job_seeker_params)
            notification = Notification.new(
                user_id: current_user.id,
                discription: "your detail has been succesfully updated"
            )
            notification.save
            render json: @job_seeker, status: :ok
        else
            render json: {
                data: @job_seeker.errors.full_messages,
                status: 'failed'
            },status: :unprocessable_entity
        end
    end
    

    private

    def set_seeker
        @job_seeker = current_user.job_seeker
    rescue ActiveRecord::RecordNotFound => error
        render json: {
            data: error.message, 
            status: :unauthorized
        },status: 404
    end

    def job_seeker_params
        params.require(:job_seeker).permit(:name, :address, :phone_no, :qualification, :skills, :hobbies, :experience, :job_field)
    end

    #def authenticate_user!
    #    jwt_payload = JWT.decode(request.headers["authorization"].split(' ')[1], Rails.application.credentials.fetch(:secret_key_base)).first
    #    current_user = User.find(jwt_payload['sub'])
    #end
end
