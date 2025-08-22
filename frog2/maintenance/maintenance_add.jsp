<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="정기점검 이력 추가" scope="request" />
<c:set var="pageBodyClass" value="page-1050 page-maintenance" scope="request" />
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ include file="/includes/header.jsp" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/customers.css">

<!-- 전체를 maintenance-add-page 클래스로 감싸기 -->
<div class="maintenance-add-page">
    <div class="container">
        <t:pageHeader>
            <jsp:attribute name="title"><i class="fas fa-plus-circle"></i> 새 정기점검 이력 등록</jsp:attribute>
            <jsp:attribute name="subtitle">
                <c:if test="${not empty customerName}"><strong>${customerName}</strong>의 정기점검 이력을 입력해주세요.</c:if>
            </jsp:attribute>
            <jsp:attribute name="actions">
                <c:choose>
                    <c:when test="${not empty customerName}">
                        <a href="${pageContext.request.contextPath}/maintenance?view=history&customerName=${customerName}" class="add-button" style="background:#6b7280"><i class="fas fa-history"></i> 이력으로</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/maintenance?view=cards" class="add-button" style="background:#6b7280"><i class="fas fa-list"></i> 카드로</a>
                    </c:otherwise>
                </c:choose>
            </jsp:attribute>
        </t:pageHeader>
        
        <!-- 오류 메시지 -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${error}
            </div>
        </c:if>
        
        <!-- 등록 폼 -->
        <div class="form-container">
            <form method="post" action="${pageContext.request.contextPath}/maintenance">
                <input type="hidden" name="action" value="add">
                
                <!-- 기본 정보 -->
                <div class="section-title">기본 정보</div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="customer_name">고객사명 <span class="required">*</span></label>
                        <c:choose>
                            <c:when test="${not empty customerName}">
                                <input type="text" id="customer_name" name="customer_name" 
                                       value="${customerName}" readonly class="readonly-field">
                            </c:when>
                            <c:otherwise>
                                <select id="customer_name" name="customer_name" required>
                                    <option value="">고객사를 선택하세요</option>
                                </select>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="form-group">
                        <label for="inspector_name">점검자 <span class="required">*</span></label>
                        <select id="inspector_name" name="inspector_name" required>
                            <option value="">점검자를 선택하세요</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="inspection_date">점검일자 <span class="required">*</span></label>
                        <input type="date" id="inspection_date" name="inspection_date" required>
                    </div>
                    <div class="form-group">
                        <label for="vertica_version">Vertica 버전</label>
                        <input type="text" id="vertica_version" name="vertica_version" placeholder="예: 12.0.4">
                    </div>
                </div>
                
                <!-- 점검 내용 -->
                <div class="section-title">점검 내용</div>
                
                <div class="form-row">
                    <div class="form-group full-width">
                        <label for="note">비고 및 점검 내용</label>
                        <textarea id="note" name="note" rows="8" placeholder="점검 내용, 발견된 이슈, 조치사항 등을 입력해주세요."></textarea>
                    </div>
                </div>
                
                <!-- 버튼 -->
                <div class="button-group">
                    <c:choose>
                        <c:when test="${not empty customerName}">
                            <a href="${pageContext.request.contextPath}/maintenance?view=history&customerName=${customerName}" class="btn btn-cancel">취소</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/maintenance?view=cards" class="btn btn-cancel">취소</a>
                        </c:otherwise>
                    </c:choose>
                    <button type="submit" class="btn btn-primary">등록하기</button>
                </div>
            </form>
        </div>
    </div>
</div>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/maintenance.css">

<script>
// 페이지 로드 시 실행
document.addEventListener('DOMContentLoaded', function() {
    // 현재 날짜 설정
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('inspection_date').value = today;
    
    // 고객사가 미리 선택된 경우가 아니라면 고객사 및 담당자 목록 로드
    const customerNameField = document.getElementById('customer_name');
    if (customerNameField.tagName === 'SELECT') {
        loadCustomersAndInspectors();
    } else {
        // 고객사가 고정된 경우 해당 고객사의 담당자 정보만 로드
        loadInspectorsOnly();
    }
});

// 고객사 및 담당자 목록 로드
function loadCustomersAndInspectors() {
    fetch('${pageContext.request.contextPath}/customers?action=getCustomersForMaintenance')
        .then(response => response.json())
        .then(data => {
            populateCustomers(data.customers);
            populateInspectors(data.inspectors);
        })
        .catch(error => {
            console.error('Error:', error);
            addDefaultOptions();
        });
}

// 담당자 목록만 로드 (고객사가 고정된 경우)
function loadInspectorsOnly() {
    fetch('${pageContext.request.contextPath}/customers?action=getCustomersForMaintenance')
        .then(response => response.json())
        .then(data => {
            populateInspectors(data.inspectors);
        })
        .catch(error => {
            console.error('Error:', error);
            addDefaultInspectors();
        });
}

// 고객사 선택박스 채우기
function populateCustomers(customers) {
    const customerSelect = document.getElementById('customer_name');
    if (customerSelect && customerSelect.tagName === 'SELECT') {
        customers.forEach(customer => {
            const option = document.createElement('option');
            option.value = customer;
            option.textContent = customer;
            customerSelect.appendChild(option);
        });
    }
}

// 점검자 선택박스 채우기
function populateInspectors(inspectors) {
    const inspectorSelect = document.getElementById('inspector_name');
    inspectors.forEach(inspector => {
        const option = document.createElement('option');
        option.value = inspector;
        option.textContent = inspector;
        inspectorSelect.appendChild(option);
    });
}

// 기본 옵션들 추가 (API 실패 시)
function addDefaultOptions() {
    const customerSelect = document.getElementById('customer_name');
    const inspectorSelect = document.getElementById('inspector_name');
    
    if (customerSelect && customerSelect.tagName === 'SELECT') {
        const defaultCustomers = ['직접 입력'];
        defaultCustomers.forEach(customer => {
            const option = document.createElement('option');
            option.value = customer;
            option.textContent = customer;
            customerSelect.appendChild(option);
        });
    }
    
    addDefaultInspectors();
}

// 기본 담당자 옵션들 추가
function addDefaultInspectors() {
    const inspectorSelect = document.getElementById('inspector_name');
    const defaultInspectors = ['직접 입력'];
    defaultInspectors.forEach(inspector => {
        const option = document.createElement('option');
        option.value = inspector;
        option.textContent = inspector;
        inspectorSelect.appendChild(option);
    });
}

// 폼 유효성 검사
document.querySelector('form').addEventListener('submit', function(e) {
    const customerName = document.getElementById('customer_name').value.trim();
    const inspectorName = document.getElementById('inspector_name').value.trim();
    const inspectionDate = document.getElementById('inspection_date').value;
    
    if (!customerName) {
        e.preventDefault();
        alert('고객사명을 선택해주세요.');
        document.getElementById('customer_name').focus();
        return false;
    }
    
    if (!inspectorName) {
        e.preventDefault();
        alert('점검자를 선택해주세요.');
        document.getElementById('inspector_name').focus();
        return false;
    }
    
    if (!inspectionDate) {
        e.preventDefault();
        alert('점검일자를 입력해주세요.');
        document.getElementById('inspection_date').focus();
        return false;
    }
});
</script>

<%@ include file="/includes/footer.jsp" %>
