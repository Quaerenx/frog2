<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="고객사 정보" scope="request" />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - 게시판 시스템</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    
    <!-- 고객사 페이지 전용 스타일 -->
    <style>
    /* 전체 페이지 배경 - 색 대비 강화 */
    body {
        background: #f5f6fa;
        min-height: 100vh;
        margin: 0;
        padding: 0;
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    }

    /* 전체 콘텐츠를 감싸는 컨테이너 - 깊이감 부여 */
    .page-container {
        width: 1100px;
        margin: 20px auto;
        max-width: 1100px;
        background: #ffffff;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        border-radius: 8px;
        overflow: hidden;
        position: relative;
        min-height: calc(100vh - 40px);
    }

    /* 배경 패턴 */
    .bg-pattern {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-image: 
            radial-gradient(circle at 25% 25%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
            radial-gradient(circle at 75% 75%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
        pointer-events: none;
        z-index: -1;
    }

    /* 헤더 스타일링 */
    .main-header {
        background-color: #FFFFFF;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
        padding: 20px 40px;
        position: sticky;
        top: 0;
        z-index: 100;
        border-bottom: 1px solid #E9E9E9;
    }

    .main-header .container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        max-width: none;
        padding: 0;
    }

    .logo {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .logo-icon {
        width: 32px;
        height: 32px;
        background-color: transparent;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .logo-text {
        font-weight: 600;
        font-size: 18px;
        color: #191919;
    }

    .main-nav ul {
        display: flex;
        list-style: none;
        margin: 0;
        padding: 0;
        gap: 24px;
    }

    .main-nav a {
        text-decoration: none;
        color: #666666;
        font-weight: 500;
        font-size: 15px;
        transition: color 0.2s ease;
    }

    .main-nav a:hover, .main-nav a.active {
        color: #3D5A80;
    }

    .main-nav a i {
        margin-right: 5px;
    }

    /* 드롭다운 메뉴 스타일 */
    .main-nav ul li.dropdown {
        position: relative;
    }

    .main-nav ul li.dropdown .dropdown-menu {
        display: none;
        position: absolute;
        top: 100%;
        left: 0;
        background-color: #FFFFFF;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
        min-width: 200px;
        z-index: 1000;
        padding: 8px 0;
        margin-top: 0;
    }

    .main-nav ul li.dropdown .dropdown-menu::before {
        content: '';
        position: absolute;
        top: -8px;
        left: 0;
        right: 0;
        height: 8px;
        background: transparent;
    }

    .main-nav ul li.dropdown:hover .dropdown-menu {
        display: block;
    }

    .main-nav ul li.dropdown .dropdown-menu li {
        display: block;
        margin: 0;
    }

    .main-nav ul li.dropdown .dropdown-menu li a {
        padding: 8px 16px;
        display: block;
        color: #666666;
        font-size: 14px;
    }

    .main-nav ul li.dropdown .dropdown-menu li a:hover {
        background-color: #EEF1F6;
        color: #3D5A80;
    }

    /* 메인 콘텐츠 영역 */
    .main-content {
        padding: 40px 40px;
        min-height: calc(100vh - 200px);
    }

    .container {
        max-width: none;
        padding: 0;
    }

    /* 페이지 헤더 - 영역 구획 명확화 */
    .page-header {
        background-color: #FFFFFF;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
        padding: 40px 40px;
        margin-bottom: 30px;
        border-radius: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 2px solid #f0f0f0;
    }

    .page-header h1 {
        font-size: 28px;
        font-weight: 600;
        color: #191919;
        margin: 0 0 8px 0;
    }

    .page-header h1 i {
        margin-right: 12px;
        color: #3D5A80;
    }

    .page-header .lead {
        color: #666666;
        margin: 0;
        font-size: 16px;
    }

    /* CTA 버튼 - 시선 흐름 유도 */
    .add-button {
        background: linear-gradient(135deg, #3D5A80 0%, #667eea 100%);
        color: white;
        padding: 15px 30px;
        border: none;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 10px;
        box-shadow: 0 4px 12px rgba(61, 90, 128, 0.2);
    }

    .add-button:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(61, 90, 128, 0.3);
        color: white;
        text-decoration: none;
    }

    /* 알림 메시지 */
    .alert {
        padding: 16px 20px;
        margin-bottom: 20px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .alert-success {
        background-color: #d4edda;
        border: 1px solid #c3e6cb;
        color: #155724;
    }

    .alert-danger {
        background-color: #f8d7da;
        border: 1px solid #f5c6cb;
        color: #721c24;
    }

    /* 필터 섹션 - 영역 구획 명확화 */
    .filter-section {
        background: #FFFFFF;
        border-radius: 8px;
        padding: 25px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid #f0f0f0;
    }

    .filter-toggle {
        display: flex;
        gap: 10px;
    }

    .filter-btn {
        padding: 12px 24px;
        border: 2px solid #E9E9E9;
        background: #FFFFFF;
        color: #666666;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
    }

    .filter-btn:hover {
        border-color: #3D5A80;
        color: #3D5A80;
        transform: translateY(-1px);
    }

    .filter-btn.active {
        background: #3D5A80;
        border-color: #3D5A80;
        color: white;
        box-shadow: 0 2px 8px rgba(61, 90, 128, 0.2);
    }

    .filter-info {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #666666;
        font-size: 14px;
    }

    /* 검색 섹션 - 보조 기능 구분 */
    .search-section {
        background: #FFFFFF;
        border-radius: 8px;
        padding: 25px;
        margin-bottom: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    }

    .search-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
    }

    .search-input-wrapper {
        position: relative;
        flex: 1;
        max-width: 400px;
    }

    .search-icon {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #666666;
        z-index: 2;
    }

    .search-input {
        width: 100%;
        padding: 12px 45px 12px 45px;
        border: 2px solid #E9E9E9;
        border-radius: 8px;
        font-size: 14px;
        transition: all 0.3s ease;
        background: #FFFFFF;
    }

    .search-input:focus {
        outline: none;
        border-color: #3D5A80;
        box-shadow: 0 0 0 3px rgba(61, 90, 128, 0.1);
    }

    .clear-search {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        color: #666666;
        cursor: pointer;
        padding: 5px;
        border-radius: 3px;
        transition: all 0.2s ease;
    }

    .clear-search:hover {
        background: #f0f0f0;
        color: #333;
    }

    .search-stats {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #666666;
        font-size: 14px;
    }

    /* 테이블 컨테이너 - 정보 목록의 시각적 정렬 강화 */
    .table-container {
        background: #FFFFFF;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        overflow: hidden;
    }

    .table-wrapper {
        overflow-x: auto;
    }

    .customer-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
    }

    /* 컬럼 헤더 배경색과 하단 border */
    .customer-table thead {
        background: #f8f9fa;
        border-bottom: 2px solid #E9E9E9;
    }

    .customer-table th {
        padding: 18px 12px;
        text-align: left;
        font-weight: 600;
        color: #191919;
        white-space: nowrap;
        background: #f8f9fa;
    }

    .customer-table th a {
        color: #191919;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .customer-table th a:hover {
        color: #3D5A80;
    }

    .sort-icon {
        color: #ccc;
        font-size: 12px;
        transition: all 0.2s ease;
    }

    .sort-icon.active {
        color: #3D5A80;
    }

    .customer-table tbody tr {
        border-bottom: 1px solid #f0f0f0;
        transition: all 0.2s ease;
    }

    .customer-table tbody tr:hover {
        background-color: #f8f9fa;
    }

    .customer-table td {
        padding: 16px 12px;
        vertical-align: middle;
        max-width: 120px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .customer-table td:first-child {
        font-weight: 500;
        color: #191919;
    }

    /* 액션 버튼 */
    .action-buttons {
        display: flex;
        gap: 8px;
    }

    .action-btn {
        width: 32px;
        height: 32px;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        text-decoration: none;
        font-size: 14px;
    }

    .detail-btn {
        background: #e3f2fd;
        color: #1976d2;
    }

    .detail-btn:hover {
        background: #bbdefb;
        color: #1565c0;
        transform: translateY(-1px);
    }

    .edit-btn {
        background: #fff3e0;
        color: #f57c00;
    }

    .edit-btn:hover {
        background: #ffe0b2;
        color: #ef6c00;
        transform: translateY(-1px);
    }

    .delete-btn {
        background: #ffebee;
        color: #d32f2f;
    }

    .delete-btn:hover {
        background: #ffcdd2;
        color: #c62828;
        transform: translateY(-1px);
    }

    /* 빈 상태 - 톤다운 처리 */
    .empty-state, .no-results {
        text-align: center;
        padding: 60px 40px;
        color: #999999;
    }

    .empty-state i, .no-results i {
        font-size: 48px;
        margin-bottom: 16px;
        color: #ddd;
    }

    .no-results h3 {
        margin: 16px 0 8px 0;
        color: #666666;
    }

    /* 숨김 처리 */
    .hidden {
        display: none !important;
    }

    .d-none {
        display: none !important;
    }

    /* 푸터 스타일링 */
    .main-footer {
        background-color: #FFFFFF;
        border-top: 1px solid #E9E9E9;
        padding: 30px 40px;
        text-align: center;
        color: #191919;
        font-size: 0.9rem;
    }

    .main-footer .container {
        max-width: none;
        padding: 0;
    }

    /* 반응형 디자인 */
    @media (max-width: 1000px) {
        .page-container {
            width: 95%;
            max-width: 95%;
            margin: 20px auto;
        }
        
        .main-content {
            padding: 30px 25px;
        }
        
        .main-header {
            padding: 20px 25px;
        }
        
        .main-footer {
            padding: 25px 25px;
        }
        
        .page-header {
            padding: 30px 25px;
            flex-direction: column;
            gap: 20px;
            text-align: center;
        }
        
        .filter-section, .search-section {
            padding: 20px;
        }
        
        .search-container {
            flex-direction: column;
            gap: 15px;
        }
        
        .search-input-wrapper {
            max-width: none;
        }
    }

    @media (max-width: 768px) {
        .page-container {
            width: 95%;
            max-width: 95%;
            margin: 15px auto;
        }
        
        .main-content {
            padding: 25px 20px;
        }
        
        .main-header {
            padding: 18px 20px;
        }
        
        .main-footer {
            padding: 20px 20px;
        }
        
        .page-header {
            padding: 25px 20px;
        }
        
        .filter-section, .search-section {
            padding: 15px;
        }
        
        .filter-toggle {
            flex-direction: column;
            gap: 8px;
        }
        
        .filter-btn {
            width: 100%;
            justify-content: center;
        }
        
        .main-nav ul {
            flex-direction: column;
            gap: 10px;
        }
        
        .main-header .container {
            flex-direction: column;
            gap: 15px;
        }
        
        .customer-table {
            font-size: 12px;
        }
        
        .customer-table th,
        .customer-table td {
            padding: 12px 8px;
        }
    }

    /* 스크롤바 스타일링 */
    .page-container::-webkit-scrollbar {
        width: 8px;
    }

    .page-container::-webkit-scrollbar-track {
        background: #f1f1f1;
    }

    .page-container::-webkit-scrollbar-thumb {
        background: linear-gradient(135deg, #3D5A80, #667eea);
    }

    .page-container::-webkit-scrollbar-thumb:hover {
        background: linear-gradient(135deg, #2d4a70, #5a6fd8);
    }
    </style>
</head>
<body>
    <!-- 배경 패턴 -->
    <div class="bg-pattern"></div>

    <!-- 전체 페이지 컨테이너 -->
    <div class="page-container">
        <!-- 헤더 -->
        <header class="main-header">
            <div class="container">
                <div class="logo">
                    <a href="${pageContext.request.contextPath}/dashboard" class="logo-icon d-flex align-items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="28" height="28">
                            <path d="M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5c0-1.1.9-2 2-2zm0 2v14h14V5H5zm2 2h10v2H7V7zm0 4h10v2H7v-2zm0 4h7v2H7v-2z" fill="#333333" opacity="0.9"/>
                        </svg>
                    </a>	
                    <span class="logo-text">업무개선</span>
                </div>
                
                <nav class="main-nav">
                    <ul>
                        <!-- 대시보드 -->
                        <li>
                            <a href="${pageContext.request.contextPath}/dashboard" class="${pageTitle eq '대시보드' ? 'active' : ''}">
                                <i class="fas fa-tachometer-alt mr-1"></i>대시보드
                            </a>
                        </li>
                        
                        <!-- 고객관리 드롭다운 -->
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle ${pageTitle eq '고객사 정보' || pageTitle eq '정기점검 이력' ? 'active' : ''}">
                                <i class="fas fa-building mr-1"></i>고객관리
                            </a>
                            <ul class="dropdown-menu">
                                <li>
                                    <a href="${pageContext.request.contextPath}/customers?view=list">
                                        <i class="fas fa-address-card mr-2"></i>고객사 정보
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/maintenance">
                                        <i class="fas fa-clipboard-check mr-2"></i>정기점검 이력
                                    </a>
                                </li>
                            </ul>
                        </li>
                        
                        <!-- 자료관리 드롭다운 -->
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle ${pageTitle eq '업무자료' || pageTitle eq '회의자료' || pageTitle eq '기타자료' ? 'active' : ''}">
                                <i class="fas fa-folder mr-1"></i>자료관리
                            </a>
                            <ul class="dropdown-menu">
                                <li>
                                    <a href="${pageContext.request.contextPath}/meeting?view=list">
                                        <i class="fas fa-clipboard-list mr-2"></i>회의록
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/downlist.jsp">
                                        <i class="fas fa-file-alt mr-2"></i>자료실
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/troubleshooting?view=list">
                                        <i class="fas fa-file-alt mr-2"></i>트러블슈팅
                                    </a>
                                </li>
                            </ul>
                        </li>
                        
                        <!-- 마이페이지 -->
                        <li>
                            <a href="http://192.168.40.70:8080" class="${pageTitle eq 'OLLAMA' ? 'active' : ''}">
                                <i class="fas fa-user mr-1"></i>OLLAMA
                            </a>
                        </li> 
                        
                        <!-- 로그아웃 -->
                        <li>
                            <a href="${pageContext.request.contextPath}/logout">
                                <i class="fas fa-sign-out-alt mr-1"></i>로그아웃
                            </a>
                        </li>
                    </ul>	
                </nav>
            </div>
        </header>

        <!-- 메인 콘텐츠 -->
        <div class="main-content">
            <div class="container">
                <!-- 페이지 헤더 -->
                <div class="page-header">
                    <div>
                        <h1><i class="fas fa-building"></i> 고객사 정보</h1>
                        <p class="lead">
                            <c:choose>
                                <c:when test="${filter == 'maintenance'}">
                                    정기점검 고객사: <strong>${currentCount}</strong>개 
                                    <span style="color: #999">(전체: ${totalCount}개)</span>
                                </c:when>
                                <c:otherwise>
                                    전체 고객사: <strong>${currentCount}</strong>개 
                                    <span style="color: #999">(정기점검: ${maintenanceCount}개)</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/customers?view=add" class="add-button">
                            <i class="fas fa-plus"></i>
                            새 고객사 추가
                        </a>
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
                
                <!-- 필터 섹션 -->
                <div class="filter-section">
                    <div class="filter-toggle">
                        <button class="filter-btn ${filter == 'maintenance' ? 'active' : ''}" 
                                onclick="changeFilter('maintenance')">
                            <i class="fas fa-clipboard-check"></i>
                            정기점검만 보기
                        </button>
                        <button class="filter-btn ${filter == 'all' ? 'active' : ''}" 
                                onclick="changeFilter('all')">
                            <i class="fas fa-list"></i>
                            전체 보기
                        </button>
                    </div>
                    <div class="filter-info">
                        <i class="fas fa-info-circle"></i>
                        <span class="filter-count">
                            <c:choose>
                                <c:when test="${filter == 'maintenance'}">
                                    정기점검 ${currentCount}개 표시 중
                                </c:when>
                                <c:otherwise>
                                    전체 ${currentCount}개 표시 중
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
                
                <!-- 검색 섹션 -->
                <div class="search-section">
                    <div class="search-container">
                        <div class="search-input-wrapper">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" 
                                   id="search-input" 
                                   class="search-input" 
                                   placeholder="고객사명, 버전, OS, 담당자 등으로 검색..."
                                   autocomplete="off">
                            <button type="button" id="clear-search" class="clear-search d-none">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <div class="search-stats">
                            <i class="fas fa-filter"></i>
                            <span id="search-count" class="search-count">전체</span>
                            <span id="search-text">결과 표시 중</span>
                        </div>
                    </div>
                </div>
                
                <!-- 테이블 -->
                <div class="table-container">
                    <div class="table-wrapper">
                        <table class="customer-table">
                            <thead>
                                <tr>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('customer_name')">
                                            고객사
                                            <i class="fas fa-sort sort-icon ${sortField == 'customer_name' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('vertica_version')">
                                            버전
                                            <i class="fas fa-sort sort-icon ${sortField == 'vertica_version' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('mode')">
                                            모드
                                            <i class="fas fa-sort sort-icon ${sortField == 'mode' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('os')">
                                            OS
                                            <i class="fas fa-sort sort-icon ${sortField == 'os' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('nodes')">
                                            노드수
                                            <i class="fas fa-sort sort-icon ${sortField == 'nodes' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('license_size')">
                                            라이선스
                                            <i class="fas fa-sort sort-icon ${sortField == 'license_size' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('said')">
                                            SAID
                                            <i class="fas fa-sort sort-icon ${sortField == 'said' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>
                                        <a href="javascript:void(0)" onclick="sortTable('manager_name')">
                                            담당자
                                            <i class="fas fa-sort sort-icon ${sortField == 'manager_name' ? 'active' : ''}"></i>
                                        </a>
                                    </th>
                                    <th>작업</th>
                                </tr>
                            </thead>
                            <tbody id="customer-table-body">
                                <c:forEach var="customer" items="${customerList}">
                                    <tr class="customer-row" 
                                        data-search-text="${customer.customerName} ${customer.verticaVersion} ${customer.mode} ${customer.os} ${customer.nodes} ${customer.licenseSize} ${customer.said} ${customer.managerName}">
                                        <td title="${customer.customerName}" data-original="${not empty customer.customerName ? customer.customerName : ''}">${not empty customer.customerName ? customer.customerName : ''}</td>
                                        <td data-original="${not empty customer.verticaVersion ? customer.verticaVersion : ''}">${not empty customer.verticaVersion ? customer.verticaVersion : ''}</td>
                                        <td data-original="${not empty customer.mode ? customer.mode : ''}">${not empty customer.mode ? customer.mode : ''}</td>
                                        <td data-original="${not empty customer.os ? customer.os : ''}">${not empty customer.os ? customer.os : ''}</td>
                                        <td data-original="${not empty customer.nodes ? customer.nodes : ''}">${not empty customer.nodes ? customer.nodes : ''}</td>
                                        <td data-original="${not empty customer.licenseSize ? customer.licenseSize : ''}">${not empty customer.licenseSize ? customer.licenseSize : ''}</td>
                                        <td data-original="${not empty customer.said ? customer.said : ''}">${not empty customer.said ? customer.said : ''}</td>
                                        <td title="${customer.managerName}" data-original="${not empty customer.managerName ? customer.managerName : ''}">${not empty customer.managerName ? customer.managerName : ''}</td>
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
                                    <tr id="empty-state">
                                        <td colspan="9" class="empty-state">
                                            <i class="fas fa-inbox"></i>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${filter == 'maintenance'}">
                                                        등록된 정기점검 고객사가 없습니다.
                                                    </c:when>
                                                    <c:otherwise>
                                                        등록된 고객사 정보가 없습니다.
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                        
                        <!-- 검색 결과 없음 메시지 -->
                        <div id="no-results" class="no-results d-none">
                            <i class="fas fa-search"></i>
                            <h3>검색 결과가 없습니다</h3>
                            <p>다른 검색어로 다시 시도해보세요.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 푸터 -->
        <footer class="main-footer">
            <div class="container">
                <p>&copy; 2025 게시판 시스템. All rights reserved.</p>
            </div>
        </footer>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        // 전역 변수
        var currentFilter = "${filter}";
        var currentSortField = "${sortField}";
        var currentSortDirection = "${sortDirection}";
        
        // jQuery 준비 완료 시 실행
        $(document).ready(function() {
            if (currentSortField && currentSortDirection) {
                var activeIcon = $('.sort-icon.active');
                activeIcon.removeClass("fa-sort").addClass(currentSortDirection === "ASC" ? "fa-sort-up" : "fa-sort-down");
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
            
            // 검색 기능 초기화
            initializeSearch();
        });
        
        // 간단한 검색 기능
        function initializeSearch() {
            var searchInput = document.getElementById('search-input');
            var clearButton = document.getElementById('clear-search');
            var searchCount = document.getElementById('search-count');
            var searchText = document.getElementById('search-text');
            
            if (!searchInput || !clearButton || !searchCount || !searchText) {
                return;
            }
            
            searchInput.addEventListener('input', function() {
                var searchTerm = this.value.toLowerCase().trim();
                var rows = document.querySelectorAll('.customer-row');
                var noResultsDiv = document.getElementById('no-results');
                var visibleCount = 0;
                
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    var searchText = row.getAttribute('data-search-text').toLowerCase();
                    
                    if (!searchTerm || searchText.includes(searchTerm)) {
                        row.classList.remove('hidden');
                        visibleCount++;
                    } else {
                        row.classList.add('hidden');
                    }
                }
                
                if (visibleCount === 0 && searchTerm) {
                    noResultsDiv.classList.remove('d-none');
                } else {
                    noResultsDiv.classList.add('d-none');
                }
                
                if (searchTerm) {
                    clearButton.classList.remove('d-none');
                    searchCount.textContent = visibleCount + '/' + rows.length;
                    searchText.textContent = '검색 결과';
                } else {
                    clearButton.classList.add('d-none');
                    searchCount.textContent = '전체';
                    searchText.textContent = '결과 표시 중';
                }
            });
            
            clearButton.addEventListener('click', function() {
                searchInput.value = '';
                searchInput.focus();
                searchInput.dispatchEvent(new Event('input'));
            });
        }
        
        // 필터 변경 함수
        function changeFilter(filter) {
            var url = '${pageContext.request.contextPath}/customers?view=list&filter=' + filter;
            if (currentSortField) {
                url += '&sortField=' + currentSortField + '&sortDirection=' + currentSortDirection;
            }
            window.location.href = url;
        }
        
        // 정렬 함수
        function sortTable(field) {
            var direction = 'ASC';
            if (currentSortField === field && currentSortDirection === 'ASC') {
                direction = 'DESC';
            }
            
            var url = '${pageContext.request.contextPath}/customers?view=list&filter=' + currentFilter + 
                      '&sortField=' + field + '&sortDirection=' + direction;
            window.location.href = url;
        }
        
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
</body>
</html>