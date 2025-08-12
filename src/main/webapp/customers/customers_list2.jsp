<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="고객사 정보" scope="request" />
<%@ include file="/includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/customers.css">

<div class="customer-management">
    <div class="page-header">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1><i class="fas fa-building"></i> 고객사 정보 </h1>
                <p class="lead">등록된 고객사: <strong>${customerList.size()}</strong>개</p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/customers?view=add" class="add-button">
                    <i class="fas fa-plus"></i>
                    새 고객사 추가
                </a>
            </div>
        </div>
    </div>
	    
	<!-- 성공/에러 메시지 표시 -->
	<c:if test="${not empty sessionScope.message}">
	    <div class="alert alert-success">
	        <i class="fas fa-check-circle"></i>
	        ${sessionScope.message}
	    </div>
	    <c:remove var="message" scope="session" />
	</c:if>
	
	<c:if test="${not empty sessionScope.error}">
	    <div class="alert alert-danger">
	        <i class="fas fa-exclamation-circle"></i>
	        ${sessionScope.error}
	    </div>
	    <c:remove var="error" scope="session" />
	</c:if>
    
    <div class="table-container">
        <div class="table-wrapper">
            <table class="customer-table">
                <thead>
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=customer_name&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                고객사
                                <i class="fas fa-sort sort-icon ${sortField == 'customer_name' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=vertica_version&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                버전
                                <i class="fas fa-sort sort-icon ${sortField == 'vertica_version' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=mode&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                모드
                                <i class="fas fa-sort sort-icon ${sortField == 'mode' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=os&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                OS
                                <i class="fas fa-sort sort-icon ${sortField == 'os' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=nodes&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                노드수
                                <i class="fas fa-sort sort-icon ${sortField == 'nodes' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=license_size&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                라이선스
                                <i class="fas fa-sort sort-icon ${sortField == 'license_size' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=said&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                SAID
                                <i class="fas fa-sort sort-icon ${sortField == 'said' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/customers?view=list&sortField=manager_name&sortDirection=${sortDirection == 'ASC' ? 'DESC' : 'ASC'}">
                                담당자
                                <i class="fas fa-sort sort-icon ${sortField == 'manager_name' ? 'active' : ''}"></i>
                            </a>
                        </th>
                        <th>작업</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="customer" items="${customerList}">
                        <tr>
                            <td title="${customer.customerName}">${customer.customerName}</td>
                            <td>${customer.verticaVersion}</td>
                            <td>${customer.mode}</td>
                            <td>${customer.os}</td>
                            <td>${customer.nodes}</td>
                            <td>${customer.licenseSize}</td>
                            <td>${customer.said}</td>
                            <td title="${customer.managerName}">${customer.managerName}</td>
							<td>
							    <div class="action-buttons">
							        <a href="javascript:void(0)" onclick="viewDetail('${customer.customerName}')" 
							           class="action-btn detail-btn" title="상세정보 보기">
							            <i class="fas fa-info-circle"></i>
							        </a>
							        <a href="javascript:void(0)" onclick="editCustomer('${customer.customerName}')" 
							           class="action-btn edit-btn" title="정보 수정">
							            <i class="fas fa-edit"></i>
							        </a>
							        <button class="action-btn delete-btn" onclick="deleteCustomer('${customer.customerName}')" title="고객사 삭제">
							            <i class="fas fa-trash"></i>
							        </button>
							    </div>
							</td>
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty customerList}">
                        <tr>
                            <td colspan="9" class="empty-state">
                                <i class="fas fa-inbox"></i>
                                <div>등록된 고객사 정보가 없습니다.</div>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // jQuery 준비 완료 시 실행
    $(document).ready(function() {
        var sortField = "${sortField}";
        var sortDirection = "${sortDirection}";
        
        if (sortField && sortDirection) {
            var icon = $("a[href*='sortField=" + sortField + "']").find(".sort-icon");
            icon.removeClass("fa-sort").addClass(sortDirection === "ASC" ? "fa-sort-up" : "fa-sort-down");
        }
        
        // 테이블 로딩 애니메이션
        $('.customer-table tbody tr').each(function(index) {
            $(this).css('animation-delay', (index * 0.05) + 's');
        });
        
        // 툴팁 기능 (긴 텍스트에 대한 hover 툴팁)
        $('.customer-table td[title]').hover(
            function() {
                if (this.offsetWidth < this.scrollWidth) {
                    $(this).attr('data-toggle', 'tooltip');
                }
            }
        );
    });
    
    // 고객사 상세보기 페이지로 이동
    function viewDetail(customerName) {
        var encodedName = encodeURIComponent(customerName);
        window.location.href = '${pageContext.request.contextPath}/customers?view=detail&customerName=' + encodedName;
    }
    
    // 고객사 수정 페이지로 이동
    function editCustomer(customerName) {
        var encodedName = encodeURIComponent(customerName);
        window.location.href = '${pageContext.request.contextPath}/customers?view=edit&name=' + encodedName;
    }
    
    // 고객사 삭제 함수
    function deleteCustomer(customerName) {
        if (confirm('정말로 "' + customerName + '" 고객사를 삭제하시겠습니까?\n\n삭제된 데이터는 복구할 수 없습니다.')) {
            // 삭제 폼 생성 및 전송 (POST 방식이므로 인코딩 불필요)
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/customers';
            
            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            
            var nameInput = document.createElement('input');
            nameInput.type = 'hidden';
            nameInput.name = 'customer_name';
            nameInput.value = customerName; // POST 방식이므로 인코딩하지 않음
            
            form.appendChild(actionInput);
            form.appendChild(nameInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>

<%@ include file="/includes/footer.jsp" %>