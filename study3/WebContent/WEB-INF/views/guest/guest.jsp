<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%
   String cp = request.getContextPath();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>spring</title>

<link rel="stylesheet" href="<%=cp%>/resource/css/style.css" type="text/css">
<link rel="stylesheet" href="<%=cp%>/resource/css/layout.css" type="text/css">
<link rel="stylesheet" href="<%=cp%>/resource/jquery/css/smoothness/jquery-ui.min.css" type="text/css">
<style type="text/css">
.guest-write {
    border: #d5d5d5 solid 1px;
    padding: 10px;
    min-height: 50px;
}
</style>
<script type="text/javascript" src="<%=cp%>/resource/js/util.js"></script>
<script type="text/javascript" src="<%=cp%>/resource/jquery/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript">
var pageNo=1;
var totalPage=1;

// 스크롤바 존재 여부
function checkScrollBar() {
	var hContent=$("body").height();
	var hWindow=$(window).height();
	if(hContent>hWindow)
		return true;
	
	return false;
}

// 무한 스크롤
$(function(){
	$(window).scroll(function() {
		if($(window).scrollTop()+100>=$(document).height()-$(window).height()) {
			if(pageNo<totalPage) {
				++pageNo;
				listPage(pageNo);
			}
		}
	});
});


$(function(){
	listPage(1);
});

function listPage(page) {
	var url="<%=cp%>/guest/list.do";
	
	$.post(url, {pageNo:page}, function(data){
		printGuest(data);
	}, "json");
}

function printGuest(data) {
	var uid="${sessionScope.member.userId}";
	
	var dataCount=data.dataCount;
	var page=data.pageNo;
	totalPage=data.total_page;
	
	var out="";
	
	if(dataCount!=0) {
		for(var idx=0; idx<data.list.length; idx++) {
			var num=data.list[idx].num;
			var userId=data.list[idx].userId;
			var userName=data.list[idx].userName;
			var content=data.list[idx].content;
			var created=data.list[idx].created;
			
			out+="    <tr height='35' bgcolor='#eeeeee' id='tr"+num+"'>";
			out+="      <td width='50%' style='padding-left: 5px; border:1px solid #cccccc; border-right:none;'>"+ userName+"</td>";
			out+="      <td width='50%' align='right' style='padding-right: 5px; border:1px solid #cccccc; border-left:none;'>" + created;
			if(uid==userId || uid=="admin") {
				out+=" | <a onclick='deleteGuest(\""+num+"\", \""+page+"\");'>삭제</a></td>" ;
			} else {
				out+=" | <a href='#'>신고</a></td>" ;
			}
			out+="    </tr>";
			out+="    <tr style='height: 50px;'>";
			out+="      <td colspan='2' style='padding: 5px;' valign='top'>"+content+"</td>";
			out+="    </tr>";
		}
	}
	$("#listGuestBody").append(out);
	
	if(! checkScrollBar() ) {
		if(pageNo < totalPage) {
			++pageNo;
			listPage(pageNo);
		}
	}
	
}

$(function(){
	$("#btnSend").click(function(){
		  var uid="${sessionScope.member.userId}";
		  
		  if(! uid) {
			  alert("로그인이 필요 하니다.");
			  return;
		  }
		  
		  // var query="content="+$("#content").val();
		  var query="content="+encodeURIComponent($("#content").val());
		  var url="<%=cp%>/guest/insert.do";
		  
		  $.ajax({
			  type:"post"
			  ,url:url
			  ,data:query
			  ,dataType:"json"
			  ,success:function(data) {
				  var state = data.state;
				  if(state=="loginFail") {
					  location.href="<%=cp%>/member/login.do";
					  return;
				  }
				  
				  $("#content").val("");

				  $("#listGuestBody").empty();
				  pageNo=1;
				  listPage(1);
			  }
		      ,beforeSend:function(){
		    	  if(! $("#content").val().trim()) {
		    		  $("#content").focus();
		    		  return false;
		    	  }
		    	  
		    	  return true;
		      }
		      ,error:function(e) {
		    	  console.log(e.responseText);
		      }
		  });

		  
	});
});

function deleteGuest(num, page) {
	if(! confirm("게시물을 삭제하시겠습니까 ?"))
		return;
	
	var url="<%=cp%>/guest/delete.do";
	
	$.post(url, {num:num}, function(data){
		var state=data.state;
		if(state=="loginFail") {
			location.href="<%=cp%>/member/login.do";
			return;
		}
		
		$("#listGuestBody").empty();
		  pageNo=1;
		  listPage(1);
		
	}, "json");
}
</script>

</head>
<body>

<div class="header">
    <jsp:include page="/WEB-INF/views/layout/header.jsp"></jsp:include>
</div>
	
<div class="container">
    <div class="body-container" style="width: 700px;">
        <div class="body-title">
            <h3><span style="font-family: Webdings">2</span> 방명록 </h3>
        </div>
        
        <div>
            
             <form name="guestForm" method="post" action="">
             <div class="guest-write">
                 <div style="clear: both;">
                         <span style="font-weight: bold;">방명록쓰기</span><span> - 타인을 비방하거나 개인정보를 유출하는 글의 게시를 삼가 주세요.</span>
                 </div>
                 <div style="clear: both; padding-top: 10px;">
                       <textarea name="content" id="content" class="boxTF" rows="3" style="display:block; width: 100%; padding: 6px 12px; box-sizing:border-box;" required="required"></textarea>
                  </div>
                  <div style="text-align: right; padding-top: 10px;">
                       <button type="button" id="btnSend" class="btn" style="padding:8px 25px;"> 등록하기 </button>
                  </div>           
            </div>
           </form>
         
           <div id="listGuest">
              <table style='width: 100%; margin: 10px auto 0px; border-spacing: 0px; border-collapse: collapse;'>
                  <thead>
                      <tr height='35'>
                          <td width='50%'>
                              <span style='color: #3EA9CD; font-weight: 700;'>방명록</span>
                              <span>[목록]</span>
                          </td>
                          <td width='50%'>&nbsp;</td>
                      </tr>
                  </thead>
                  <tbody id="listGuestBody"></tbody>
              </table>
           </div>
                    
        </div>
    </div>
</div>

<div class="footer">
    <jsp:include page="/WEB-INF/views/layout/footer.jsp"></jsp:include>
</div>

<script type="text/javascript" src="<%=cp%>/resource/jquery/js/jquery-ui.min.js"></script>
<script type="text/javascript" src="<%=cp%>/resource/jquery/js/jquery.ui.datepicker-ko.js"></script>
</body>
</html>