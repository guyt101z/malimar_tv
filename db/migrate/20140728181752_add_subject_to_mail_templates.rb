class AddSubjectToMailTemplates < ActiveRecord::Migration
  def change
    add_column :mail_templates, :subject, :string
  end
end
