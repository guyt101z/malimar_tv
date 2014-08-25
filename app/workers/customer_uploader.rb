class CustomerUploader
    @queue = :customer_uploader

    def self.perform(upload_id)
        upload = ClientMigration.find(upload_id)

        file = File.open("#{Rails.root}/public#{upload.file_url}")

        if upload.file_url.end_with?('.csv')
            roo_file = Roo::Csv.new(file.path, nil, :ignore)
        elsif upload.file_url.end_with?('.xls')
            roo_file = Roo::Excel.new(file.path, nil, :ignore)
        elsif upload.file_url.end_with?('.xlsx')
            roo_file = Roo::Excelx.new(file.path, nil, :ignore)
        end

        header = roo_file.row(1)
        (2..roo_file.last_row).each do |i|
            row = Hash[[header, roo_file.row(i)].transpose]

            Resque.enqueue(CustomerParser, row)
        end
        upload.status = true

        upload.save

    end
end
