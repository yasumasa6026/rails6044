#
# config/application.rb 
#    config.autoload_paths += %W(#{config.root}/app/lib/constants.rb)
#
module Constants
    Ftype = {}
      strsql = %Q&select pobject_code_fld,fieldcode_ftype from r_fieldcodes
                       where fieldcode_expiredate >= current_date &
      ActiveRecord::Base.connection.select_all(strsql).each do |rec|
             Ftype[rec["pobject_code_fld"]] = rec["fieldcode_ftype"]
      end

    BeginnigDate = "2000-01-01"
    EndDate = "2099-12-31"
    MinDuedate = "2099-12-31 23:59:59"  ###最小納期
       
          ###マテリアライズドビュー
    Materiallized = {"scrlvs"=>["r_screens","r_screenfields"],
                 "pobjects"=>["r_pobjects","r_fieldcodes","r_blktbs","r_tblfields","r_screens","r_screenfields"],
                 "fieldcodes"=>["r_fieldcodes","r_tblfields","r_screenfields"],
                 "blktbs"=>["r_blktbs","r_tblfields","r_screenfields"],
                 "tblfields"=>["r_tblfields","r_screenfields"],
                 "screens"=>["r_screens","r_screenfields"],
                 "screenfields"=>["r_screenfields"]}
 
    Tblfield_materiallized = ["r_pobjects","r_screenfields"]

          ##calendar
    Calendar_cnt = 400  ###create_calendarの未来の最大作成日

    Whr = 8  ###壱日の労働時間

    NilOpeitmsId = "99999999"  ###opeitms.idがなっかった場合の値
    MaxSplitCnt = 10  ###最大分割数

end
