class Theme
    attr_reader :name

    def initialize theme_name
        @name = theme_name
    end

    def page_root
        return "themes/#{name}/"
    end

    def email_root
        return "themes/#{name}/mailer/"
    end

    def views
        puts Rails.root.join('app/views/', page_root)
        return ["store/home"]
    end

    def emails
        files = Dir.chdir(Rails.root.join('app/views/', email_root)){ Dir.glob("**/*") }
        files.map do |path|
            path.split('.')[0]
        end.compact
    end
end
