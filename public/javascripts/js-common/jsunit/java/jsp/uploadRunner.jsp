<%@ page import="net.jsunit.JsUnitServer" %>
<%@ page import="net.jsunit.ServerRegistry" %>
<%JsUnitServer server = ServerRegistry.getServer();%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>JsUnit Server - UploadRunner</title>
    <script type="text/javascript" src="app/jsUnitCore.js"></script>
    <script type="text/javascript" src="app/server/jsUnitVersionCheck.js"></script>
    <script type="text/javascript">

        function removeReferencedJsFile(anId) {
            var theRow = document.getElementById(anId);
            theRow.parentNode.removeChild(theRow);
        }

        function addReferencedJsFile() {
            var id = new Date().getTime();

            var rowNode = document.createElement("tr");
            rowNode.setAttribute("id", id);
            var leftCellNode = document.createElement("td");
            leftCellNode.appendChild(document.createTextNode(".js file:"));

            rowNode.appendChild(leftCellNode);

            var middleCellNode = document.createElement("td");
            middleCellNode.setAttribute("width", "1");
            var fileUploadField = document.createElement("input");
            fileUploadField.setAttribute("type", "file");
            fileUploadField.setAttribute("name", "referencedJsFiles");
            middleCellNode.appendChild(fileUploadField);

            rowNode.appendChild(middleCellNode);

            var rightCellNode = document.createElement("td");
            rightCellNode.setAttribute("align", "left");
            var fontElement = document.createElement("font");
            fontElement.setAttribute("size", "-2");
            var removeLink = document.createElement("a");
            removeLink.setAttribute("href", "javascript:removeReferencedJsFile(\"" + id + "\")");
            removeLink.appendChild(document.createTextNode("[remove]"));
            fontElement.appendChild(removeLink);
            rightCellNode.appendChild(fontElement);

            rowNode.appendChild(rightCellNode);

            var addReferencedJsFileRowNode = document.getElementById("addReferencedJsFileRow");
            var rowParentNode = addReferencedJsFileRowNode.parentNode;
            rowParentNode.insertBefore(rowNode, addReferencedJsFileRowNode);
        }

    </script>
    <link rel="stylesheet" type="text/css" href="./css/jsUnitStyle.css">
</head>

<body>
<jsp:include page="header.jsp"/>
<form action="/jsunit/runner" method="post" target="resultsFrame" enctype="multipart/form-data">
    <table cellpadding="0" cellspacing="0">
        <jsp:include page="tabRow.jsp">
            <jsp:param name="selectedPage" value="uploadRunner"/>
        </jsp:include>
        <tr>
            <td colspan="13" style="border-style: solid;border-bottom-width:1px;border-top-width:0px;border-left-width:1px;border-right-width:1px;">
                <table>
                    <tr>
                        <td colspan="3">
                            You can upload a Test Page and ask the server to run it using the <i>upload runner</i>
                            service.
                            Select your Test Page and any referenced .js files below; choose a specific browser and/or
                            skin if
                            desired.<br/>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap width="10%" valign="top">
                            Test Page:
                        </td>
                        <td width="10%">
                            <input type="file" name="testPageFile">
                        </td>
                        <td width="80%">
                            &nbsp;
                        </td>
                    </tr>
                    <%

                        String countString = request.getParameter("referencedJsFileFieldCount");
                        if (countString != null) {
                            int count = Integer.parseInt(countString);
                            for (int i = 0; i < count; i++) {

                    %>
                    <tr id="defaultReferencedJsFileField<%=i%>">
                        <td>.js file</td>
                        <td align="left" width="1"><input type="file" name="referencedJsFiles"></td>
                        <td><font size="-2">
                            <a href="javascript:removeReferencedJsFile('defaultReferencedJsFileField<%=i%>')">[remove]</a>
                        </font></td>
                    </tr>
                    <%

                            }
                        }

                    %>
                    <tr id="addReferencedJsFileRow">
                        <td>&nbsp;</td>
                        <td colspan="2">
                            <font size="-2"><a href="javascript:addReferencedJsFile()" id="addReferencedJsFile">add
                                referenced
                                .js file</a></font>
                        </td>
                    </tr>
                    <jsp:include page="browserSkinAndGo.jsp"/>
                </table>
            </td></tr></table>
</form>
<br>
<font size="-2">Server output:</font>
<br>
<iframe name="resultsFrame" width="100%" height="250" border="0"></iframe>

</body>
</html>