  
#http://sainu.hatenablog.jp/entry/2018/08/11/194319
# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,  :timeoutable, :omniauthable
  include DeviseTokenAuth::Concerns::User
end