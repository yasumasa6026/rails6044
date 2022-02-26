class CreateImportexcels < ActiveRecord::Migration[6.0]
  def change
    create_table :importexcels do |t|
      t.string :title
      t.string :filename

      t.timestamps
    end
  end
end
