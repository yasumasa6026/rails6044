class Upload < ApplicationRecord
    has_one_attached :excel
    ##   validates :excel, file_size: { in: 1.kilobytes..100.kilobytes },  ##ArgumentError (Unknown validator: 'FileSizeValidator'):
    ##                      file_content_type: { allow: ['excel/xlsx', 'excel/xls'] }
end