class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken
        before_action :authenticate_api_user!,except:[:create]
        # ###fieldcodes 修正時には、再起動が必要
        #  $ftype = {}
        #  ###before_action :load_fieldcodes
        #  :load_fieldcodes
       
        #  ###private
       
        #   def load_fieldcodes  ###dbのtypeを取得する
        #     strsql = %Q&select pobject_code_fld,fieldcode_ftype from r_fieldcodes
        #                where fieldcode_expiredate >= current_date &
        #     ActiveRecord::Base.connection.select_all(strsql).each do |rec|
        #       $ftype[rec["pobject_code_fld"]] = rec["fieldcode_ftype"]
        #     end
        #   end

        #   $beginnig_date = "2000-01-01"
        #   $end_date = "2099-12-31"
       
        #   ###マテリアライズドビュー
        #   $materiallized = {"scrlvs"=>["r_screens","r_screenfields"],
        #          "pobjects"=>["r_pobjects","r_fieldcodes","r_blktbs","r_tblfields","r_screens","r_screenfields"],
        #          "fieldcodes"=>["r_fieldcodes","r_tblfields","r_screenfields"],
        #          "blktbs"=>["r_blktbs","r_tblfields","r_screenfields"],
        #          "tblfields"=>["r_tblfields","r_screenfields"],
        #          "screens"=>["r_screens","r_screenfields"],
        #          "screenfields"=>["r_screenfields"]}
 
        #   $tblfield_materiallized = ["r_pobjects","r_screenfields"]

        #   ### calendar
        #   $calendar_cnt = 400  ###create_calendarの未来の最大作成日

        ### Parameters: 
        # "email"=>"system@rrrp.com"
        # "screenFlg"=>"first"
        # "view"=>"r_tblfields"
        # "screenCode"=>"r_tblfields","screenName"=>"テーブル項目一覧"
        # "aud"=>"edit"
        # "pageIndex"=>"0"
        # "pageSize"=>"20"
        # "index"=>"14" 
        # "pageCount"=>"3"
        # "totalCount"=>"59",
        # "disableFilters"=>"false"
        # "filtered"=>["{\"id\":\"pobject_code_tbl\",\"value\":\"opeitms\"}"]
        # "where_str"=>"    
        # "aggregations"=>"{}"
        # "buttonflg"=>"confirm7"
        # "person_code_upd"=>"0" "person_name_upd"=>"system", "person_id_upd"=>"0"
        # "clickIndex"=>["{\"lineId\":14,\"id\":\"5035\",\"screenCode\":\"r_tblfields\"}"]
        # "lineData"=>"{\"confirm\":false,\"confirm_gridmessage\":\"doing\",\"pobject_code_tbl\":\"opeitms\",
        # "parse_linedata"=>"{}"
        # "message"=>""
        # "err"=>"" 
end
