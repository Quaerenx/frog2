<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="대시보드" scope="request" />

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${pageTitle}</title>
  <!-- 기본 스타일 로드 (헤더/푸터 없이 카드만 사용) -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main_style.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/utilities.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/dashboard.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/dashboard_box.css">
</head>
<body class="page-1050">
  <%@ include file="/includes/header.jsp" %>

    <div class="page-body">
      <div class="dashboard-management">
        <div class="greeting-bar">
          <div class="greeting-text">안녕하세요, ${user.userName}님</div>
        </div>
        <div class="card-grid">
        <c:forEach var="entry" items="${dashboardMenus}">
          <div class="card-item">
            <div class="card dashboard-card">
              <div class="card-header">
                <i class="fas fa-th-large"></i> ${entry.key}
              </div>
              <div class="card-body">
                <ul class="dashboard-submenu">
                  <c:forEach var="menuItem" items="${entry.value}">
                    <li>
                      <a href="${pageContext.request.contextPath}/${menuItem.url}">
                        <i class="${menuItem.icon} mr-2"></i>${menuItem.title}
                      </a>
                    </li>
                  </c:forEach>
                </ul>
              </div>
            </div>
          </div>
        </c:forEach>
        </div>
      </div>
    </div>

  <%@ include file="/includes/footer.jsp" %>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</body>
</html>