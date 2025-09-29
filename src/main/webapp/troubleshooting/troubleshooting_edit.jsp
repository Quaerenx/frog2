<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="트러블 슈팅 수정" scope="request" />
<%@ include file="/includes/header.jsp" %>

<div class="edit-page">
    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-edit"></i> 트러블 슈팅 수정</h2>
            <p>"<strong>${troubleshooting.title}</strong>" 정보를 수정합니다.</p>
        </div>
    
    <!-- 오류 메시지 -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i> ${error}
        </div>
    </c:if>
    
    <!-- 수정 폼 -->
    <div class="form-container">
        <form method="post" action="${pageContext.request.contextPath}/troubleshooting">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="${troubleshooting.id}">
            
            <!-- 기본작성 항목 -->
            <div class="section-title">기본작성 항목</div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="title">제목 <span class="required">*</span></label>
                    <input type="text" id="title" name="title" value="${troubleshooting.title}" required placeholder="문제 상황을 간략히 입력하세요">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="customer_name">고객사 <span class="required">*</span></label>
                    <select id="customer_name" name="customer_name" required>
                        <option value="">고객사를 선택하세요</option>
                        <c:forEach var="customer" items="${customerList}">
                            <option value="${customer.customerName}" ${troubleshooting.customerName == customer.customerName ? 'selected' : ''}>${customer.customerName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label for="occurrence_date">발생일자</label>
                    <input type="date" id="occurrence_date" name="occurrence_date" 
                           value="<c:if test='${not empty troubleshooting.occurrenceDate}'><fmt:formatDate value='${troubleshooting.occurrenceDate}' pattern='yyyy-MM-dd' /></c:if>">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="customer_manager">고객사 담당자</label>
                    <input type="text" id="customer_manager" name="customer_manager" value="${troubleshooting.customerManager}" placeholder="고객사 담당자명">
                </div>
                <div class="form-group">
                    <label for="work_period">작업기간</label>
                    <input type="text" id="work_period" name="work_period" value="${troubleshooting.workPeriod}" placeholder="예: 2시간, 1일">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="work_personnel">작업인원</label>
                    <input type="text" id="work_personnel" name="work_personnel" value="${troubleshooting.workPersonnel}" placeholder="작업에 참여한 인원">
                </div>
                <div class="form-group">
                    <label for="support_type">지원형태</label>
                    <select id="support_type" name="support_type">
                        <option value="">선택하세요</option>
                        <option value="방문" ${troubleshooting.supportType == '방문' ? 'selected' : ''}>방문</option>
                        <option value="원격" ${troubleshooting.supportType == '원격' ? 'selected' : ''}>원격</option>
                    </select>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="case_open_yn">케이스오픈 여부</label>
                    <select id="case_open_yn" name="case_open_yn">
                        <option value="">선택하세요</option>
                        <option value="Y" ${troubleshooting.caseOpenYn == 'Y' ? 'selected' : ''}>예</option>
                        <option value="N" ${troubleshooting.caseOpenYn == 'N' ? 'selected' : ''}>아니오</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>작성자</label>
                    <input type="text" value="${troubleshooting.creator}" readonly 
                           class="bg-light text-muted">
                </div>
            </div>
            
            <!-- 세부작성 항목 -->
            <div class="section-title">세부작성 항목</div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="overview">개요</label>
                    <textarea id="overview" name="overview" rows="3" placeholder="문제 상황의 전반적인 개요를 작성하세요">${troubleshooting.overview}</textarea>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="cause_analysis">원인</label>
                    <textarea id="cause_analysis" name="cause_analysis" rows="3" placeholder="문제 발생 원인 분석">${troubleshooting.causeAnalysis}</textarea>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="error_content">에러내용</label>
                    <textarea id="error_content" name="error_content" rows="4" placeholder="발생한 에러 메시지나 증상을 상세히 기록하세요">${troubleshooting.errorContent}</textarea>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="action_taken">조치내용</label>
                    <textarea id="action_taken" name="action_taken" rows="4" placeholder="문제 해결을 위해 수행한 조치사항을 기록하세요">${troubleshooting.actionTaken}</textarea>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="script_content">스크립트</label>
                    <textarea id="script_content" name="script_content" rows="6" placeholder="사용한 SQL문, 스크립트, 명령어 등을 기록하세요">${troubleshooting.scriptContent}</textarea>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="note">비고</label>
                    <textarea id="note" name="note" rows="3" placeholder="추가 참고사항이나 특이사항을 기록하세요">${troubleshooting.note}</textarea>
                </div>
            </div>
            
            <!-- 버튼 -->
            <div class="button-group">
                <a href="${pageContext.request.contextPath}/troubleshooting?view=list" class="btn btn-cancel">취소</a>
                <a href="${pageContext.request.contextPath}/troubleshooting?view=view&id=${troubleshooting.id}" class="btn btn-secondary">상세보기</a>
                <button type="submit" class="btn btn-primary">수정 완료</button>
            </div>
        </form>
    </div>
</div>
</div>

<style>
/* edit.jsp의 <style> 태그 내용을 다음과 같이 수정하세요 */

/* 모든 스타일을 .edit-page 클래스 하위로 제한 */
.edit-page .container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 20px;
}

.edit-page .page-header {
    margin-bottom: 30px;
    text-align: center;
}

.edit-page .page-header h2 {
    color: #333;
    margin-bottom: 10px;
}

.edit-page .page-header p {
    color: #666;
    margin: 0;
}

/* 폼 컨테이너 */
.edit-page .form-container {
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 30px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* 섹션 제목 */
.edit-page .section-title {
    font-size: 16px;
    font-weight: bold;
    color: #333;
    margin: 25px 0 15px 0;
    padding-bottom: 8px;
    border-bottom: 2px solid #007bff;
}

.edit-page .section-title:first-child {
    margin-top: 0;
}

/* 폼 행 */
.edit-page .form-row {
    display: flex;
    gap: 20px;
    margin-bottom: 15px;
}

.edit-page .form-group {
    flex: 1;
}

.edit-page .form-group.full-width {
    flex: 1 1 100%;
}

/* 라벨 */
.edit-page .form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: 500;
    color: #333;
    font-size: 14px;
}

.edit-page .required {
    color: #dc3545;
}

/* 입력 필드 */
.edit-page .form-group input,
.edit-page .form-group select,
.edit-page .form-group textarea {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
    background: white;
    transition: border-color 0.2s;
    box-sizing: border-box;
}

.edit-page .form-group input:focus,
.edit-page .form-group select:focus,
.edit-page .form-group textarea:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
}

.edit-page .form-group textarea {
    resize: vertical;
    min-height: 80px;
    font-family: monospace;
}

/* 버튼 그룹 */
.edit-page .button-group {
    text-align: center;
    margin-top: 30px;
    padding-top: 20px;
    border-top: 1px solid #eee;
}

.edit-page .btn {
    display: inline-block;
    padding: 12px 24px;
    margin: 0 5px;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: 500;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.2s;
}

.edit-page .btn-primary {
    background: #007bff;
    color: white;
}

.edit-page .btn-primary:hover {
    background: #0056b3;
}

.edit-page .btn-secondary {
    background: #6c757d;
    color: white;
}

.edit-page .btn-secondary:hover {
    background: #545b62;
    text-decoration: none;
}

.edit-page .btn-cancel {
    background: #6c757d;
    color: white;
}

.edit-page .btn-cancel:hover {
    background: #545b62;
    text-decoration: none;
}

/* 알림 메시지 */
.edit-page .alert {
    padding: 12px 16px;
    margin-bottom: 20px;
    border-radius: 4px;
    border: 1px solid transparent;
}

.edit-page .alert-danger {
    color: #721c24;
    background-color: #f8d7da;
    border-color: #f5c6cb;
}

/* 반응형 */
@media (max-width: 768px) {
    .edit-page .container {
        padding: 15px;
    }
    
    .edit-page .form-container {
        padding: 20px;
    }
    
    .edit-page .form-row {
        flex-direction: column;
        gap: 10px;
    }
    
    .edit-page .form-group {
        flex: none;
    }
    
    .edit-page .button-group {
        text-align: stretch;
    }
    
    .edit-page .btn {
        display: block;
        width: 100%;
        margin: 5px 0;
    }
}
</style>

<script>
// 폼 유효성 검사 및 확인
document.querySelector('form').addEventListener('submit', function(e) {
    const title = document.getElementById('title').value.trim();
    const customerName = document.getElementById('customer_name').value;
    
    if (!title) {
        e.preventDefault();
        alert('제목은 필수 입력 항목입니다.');
        document.getElementById('title').focus();
        return false;
    }
    
    if (!customerName) {
        e.preventDefault();
        alert('고객사는 필수 선택 항목입니다.');
        document.getElementById('customer_name').focus();
        return false;
    }
    
    if (!confirm('트러블 슈팅 정보를 수정하시겠습니까?')) {
        e.preventDefault();
        return false;
    }
});

// 페이지 로드 시 포커스
document.addEventListener('DOMContentLoaded', function() {
    // 첫 번째 편집 가능한 필드에 포커스
    const firstInput = document.querySelector('#title');
    if (firstInput) {
        firstInput.focus();
    }
});
</script>

<%@ include file="/includes/footer.jsp" %>
