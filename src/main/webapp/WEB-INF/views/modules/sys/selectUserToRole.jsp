<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<html>
<head>
	<title>分配角色</title>
	<%@include file="/WEB-INF/views/include/head.jsp" %>
	<%@include file="/WEB-INF/views/include/treeview.jsp" %>
	<meta name="decorator" content="default"/>
	<script type="text/javascript">
	
		var officeTree;
		var selectedTree;//zTree已选择对象
		
		// 初始化
		$(document).ready(function(){
			officeTree = $.fn.zTree.init($("#officeTree"), setting, officeNodes);
			selectedTree = $.fn.zTree.init($("#selectedTree"), setting, selectedNodes);
		});

		var setting = {view: {selectedMulti:false,nameIsHTML:true},
				data: {simpleData: {enable: true}},
				callback: {onClick: treeOnClick}};
		
		var officeNodes=[
	            <c:forEach items="${officeList}" var="office">
	            {id:"${office.id}",
	             pId:"${not empty office.parent?office.parent.id:0}", 
	             name:"${office.name}"},
	            </c:forEach>];
	
		var pre_selectedNodes =[
   		        <c:forEach items="${selectedList}" var="user">
   		        {id:"${user.id}",
   		         pId:"0",
   		         name:"<font color='red' style='font-weight:bold;'>${user.name}</font>"},
   		        </c:forEach>];
		
		var selectedNodes =[
		        <c:forEach items="${selectedList}" var="user">
		        {id:"${user.id}",
		         pId:"0",
		         name:"<font color='red' style='font-weight:bold;'>${user.name}</font>"},
		        </c:forEach>];
		
		var pre_ids = "${selectIds}".split(",");
		var ids = "${selectIds}".split(",");
		
		//点击选择项回调
		function treeOnClick(event, treeId, treeNode, clickFlag){
			if("officeTree"==treeId){
				$.get("${ctx}/sys/role/users?officeId=" + treeNode.id, function(userNodes){
					$.fn.zTree.init($("#userTree"), setting, userNodes);
				});
			}
			if("userTree"==treeId){
				//alert(treeNode.id + " | " + ids);
				//alert(typeof ids[0] + " | " +  typeof treeNode.id);
				if($.inArray(String(treeNode.id), ids)<0){
					selectedTree.addNodes(null, treeNode);
					ids.push(String(treeNode.id));
				}
			};
		};
	</script>
</head>
<body>
	<div class="breadcrumb">
		<a id="assignButton" href="javascript:" class="btn btn-primary">确认分配</a>
		<script type="text/javascript">
			$("#assignButton").click(function(){
				// 删除''的元素
				if(ids[0]==''){
					ids.shift();
					pre_ids.shift();
				}
				if(pre_ids.sort().toString() == ids.sort().toString()){
					top.$.jBox.tip("未给角色【${role.name}】分配新成员！", 'info');
					return;
				};
				
				// 要修改的地方！！！
				var submit = function (v, h, f) {
				    if (v == 'ok'){
				    	// 执行保存
				    	var idsArr = "";
				    	for (var i = 0; i<ids.length; i++) {
				    		idsArr = (idsArr + ids[i]) + (((i + 1)== ids.length) ? '':',');
				    	}
				    	var postForm = document.createElement("form");
				    	postForm.method="post" ; 
				    	postForm.action="${ctx}/sys/role/assignrole?roleId=${role.id}&idsArr="+idsArr;
				    	postForm.submit();
				    	//top.$.jBox("post:${ctx}/sys/role/assignrole?roleId=${role.id}&idsArr="+idsArr);
				    	return true;
				    } else if (v == 'cancel'){
				    	// 取消
				    	top.$.jBox.tip("取消分配操作！", 'info');
				    };
				};
				
				var tips="新增【"+ (ids.length-pre_ids.length) +"个】用户到角色【${role.name}】？";
				if(ids.length==0){
					tips="确定清空角色【${role.name}】下的所有人员？";
				}
				
				top.$.jBox.confirm(tips, "分配确认", submit);
			});
		</script>
		<a id="clearButton" href="javascript:" class="btn">清除已选</a>
		<script type="text/javascript">
			$("#clearButton").click(function(){
				var submit = function (v, h, f) {
				    if (v == 'ok'){
						ids=pre_ids.slice(0);
						selectedNodes=pre_selectedNodes;
						$.fn.zTree.init($("#selectedTree"), setting, selectedNodes);
				    	top.$.jBox.tip("角色【${role.name}】清除成功！", 'info');		    	
				    } else if (v == 'cancel'){
				    	// 取消
				    	top.$.jBox.tip("取消清除操作！", 'info');
				    }
				    return true;
				};
				tips="确定清除角色【${role.name}】下的已选人员？";
				top.$.jBox.confirm(tips, "清除确认", submit);
			});
		</script>
	</div>
	<div id="assignRole" class="row-fluid span12">
		<div class="span4" style="border-right: 1px solid #A8A8A8;">
			<p>所在部门：</p>
			<div id="officeTree" class="ztree"></div>
		</div>
		<div class="span4">
			<p>待选人员：</p>
			<div id="userTree" class="ztree"></div>
		</div>
		<div class="span4" style="padding-left:16px;border-left: 1px solid #A8A8A8;">
			<p>已选人员：</p>
			<div id="selectedTree" class="ztree"></div>
		</div>
	</div>
</body>
</html>