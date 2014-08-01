class CreateMailTemplates < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
      t.string :name
      t.text :body
      t.text :css
      t.text :required_variables #Hash YAML
      t.timestamps
    end
  end
end
