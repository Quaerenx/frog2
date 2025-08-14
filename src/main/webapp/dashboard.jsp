<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="대시보드" scope="request" />
<c:set var="pageBodyClass" value="page-1050 page-customers" scope="request" />
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

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
  <!-- 고객사 페이지 공통 톤(헤더/버튼)을 재사용 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/customers.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/dashboard_box.css">
</head>
<body class="page-1050 page-customers">
  <%@ include file="/includes/header.jsp" %>

    <div class="customer-management">
        <t:pageHeader>
          <jsp:attribute name="title"><i class="fas fa-th-large"></i> 대시보드</jsp:attribute>
          <jsp:attribute name="subtitle">
            업무 바로가기와 핵심 메뉴를 한눈에 확인하세요
            <br/>
            <span style="display:block; margin-top:6px; font-weight:600;">안녕하세요 <c:out value="${sessionScope.user != null ? sessionScope.user.userName : ''}"/> 님</span>
          </jsp:attribute>
        </t:pageHeader>
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
                    <c:set var="resolvedUrl" value="${menuItem.url}" />
                    <c:if test="${resolvedUrl == 'downlist.jsp'}">
                      <c:set var="resolvedUrl" value="filerepo/filerepo_downlist.jsp" />
                    </c:if>
                    <li>
                      <a href="${pageContext.request.contextPath}/${resolvedUrl}">
                        <i class="${menuItem.icon} mr-2"></i>${menuItem.title}
                      </a>
                    </li>
                  </c:forEach>
                </ul>
              </div>
            </div>
          </div>
        </c:forEach>
          <!-- 추가 카드: 임의 이미지 표시 -->
          <div class="card-item">
            <div class="card dashboard-card">
              <div class="card-header">
                <i class="fas fa-image"></i> 임시
              </div>
              <div class="card-body text-center">
                <a href="https://x2wizard.github.io/" target="_blank" rel="noopener noreferrer">
                  <img src="${pageContext.request.contextPath}/resources/images/images/ollama.png" alt="sample" style="max-width:100%; height:auto; border-radius:6px;" />
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

  <%@ include file="/includes/footer.jsp" %>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</body>
</html>