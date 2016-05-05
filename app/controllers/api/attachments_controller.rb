class Api::AttachmentsController < ApiController
    S3_URL = 'https://s3-eu-west-1.amazonaws.com/gimson-robotics-production/'

    def s3_froala_uploads
        s3_resource_sdk
        set_bucket
        set_s3_objects
        render json: @s3_objects.map{|o| o.key == 'froala/uploads/' ? next : s3_object_serialisation(o) }.compact, status: 200
    end

    def delete_s3_froala_upload
        s3_resource_sdk
        set_bucket
        set_object_key
        destroy_s3_object
        render json: { }, status: 200
    end

    private

    def set_bucket
        @bucket = @s3.bucket('gimson-robotics-production')
    end

    def set_s3_objects
        @s3_objects = @bucket.objects(prefix: 'froala/uploads')
    end

    def s3_object_serialisation o
        {
            url: "#{S3_URL}#{o.key}",
            thumb: "#{S3_URL}#{o.key}"
        }
    end

    def set_object_key
        @object_key = params[:src].split(S3_URL).last
    end

    def destroy_s3_object 
        @bucket.object(@object_key).delete
    end
end