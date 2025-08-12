<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="대시보드 테스트" scope="request" />

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
    
    <!-- 테스트 페이지 전용 스타일 -->
    <style>
    /* 전체 페이지 배경 */
    body {
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        min-height: 100vh;
        margin: 0;
        padding: 0;
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    }

    /* 전체 콘텐츠를 감싸는 컨테이너 */
    .page-container {
        width: 1100px;
        margin: 0 auto;
        max-width: 1100px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
        overflow: hidden;
        position: relative;
        min-height: calc(100vh - 60px);
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

    /* 헤더 스타일링 - 여백 개선 */
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

    /* 메인 콘텐츠 영역 - 여백 개선 */
    .main-content {
        padding: 40px 40px;
        min-height: calc(100vh - 200px);
    }

    .container {
        max-width: none;
        padding: 0;
    }

    /* 헤더 영역 스타일링 - 여백 개선 */
    .jumbotron {
        background-color: #FFFFFF;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
        padding: 50px 40px;
        margin-bottom: 40px;
        text-align: center;
        position: relative;
        overflow: hidden;
        border-radius: 8px;
    }

    .jumbotron::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, rgba(255,255,255,0.1) 0%, transparent 50%, rgba(255,255,255,0.1) 100%);
        animation: shimmer 3s ease-in-out infinite;
    }

    @keyframes shimmer {
        0%, 100% { transform: translateX(-100%); }
        50% { transform: translateX(100%); }
    }

    .jumbotron h1 {
        font-size: 24px;
        font-weight: 600;
        color: #191919;
        margin-bottom: 8px;
        position: relative;
        z-index: 1;
    }

    .jumbotron .lead {
        font-size: 1.2rem;
        opacity: 0.9;
        position: relative;
        z-index: 1;
    }

    /* 콘텐츠 섹션 스타일링 */
    .content-section {
        margin-bottom: 40px;
    }

    .section-title {
        font-size: 1.8rem;
        font-weight: 600;
        color: #191919;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 2px solid #E9E9E9;
    }

    .section-title i {
        margin-right: 10px;
        color: #3D5A80;
    }

    /* 메뉴 그리드 */
    .menu-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 30px;
        margin-bottom: 40px;
    }

    /* 메뉴 카테고리 - 여백 개선 */
    .menu-category {
        background: #F7F7F7;
        border: 1px solid #E9E9E9;
        transition: all 0.3s ease;
        padding: 30px;
        border-radius: 8px;
    }

    .menu-category:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        border-color: #3D5A80;
    }

    .category-title {
        font-size: 1.3rem;
        font-weight: 600;
        color: #191919;
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .category-title i {
        color: #3D5A80;
        font-size: 1.2rem;
    }

    .menu-list {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .menu-list li {
        margin-bottom: 12px;
    }

    .menu-list a {
        display: flex;
        align-items: center;
        padding: 12px 15px;
        color: #191919;
        text-decoration: none;
        transition: all 0.3s ease;
        background: #FFFFFF;
        border: 1px solid transparent;
    }

    .menu-list a:hover {
        background: linear-gradient(135deg, #3D5A80 0%, #667eea 100%);
        color: white;
        transform: translateX(5px);
        box-shadow: 0 5px 15px rgba(61, 90, 128, 0.3);
    }

    .menu-list a i {
        margin-right: 10px;
        width: 20px;
        text-align: center;
    }

    /* 푸터 스타일링 - 여백 개선 */
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

    /* 정보 섹션 - 여백 개선 */
    .info-section {
        background: #F7F7F7;
        border: 1px solid #E9E9E9;
        margin-top: 40px;
        padding: 30px;
        border-radius: 8px;
    }

    .info-section h3 {
        color: #191919;
        margin-bottom: 15px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .info-section h3 i {
        color: #3D5A80;
    }

    .info-section p {
        color: #666666;
        line-height: 1.6;
        margin-bottom: 15px;
    }

    .info-section ul {
        color: #666666;
        line-height: 1.6;
        padding-left: 20px;
    }

    .info-section li {
        margin-bottom: 8px;
    }

    /* 반응형 디자인 - 여백 개선 */
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
        
        .jumbotron {
            padding: 40px 25px;
        }
        
        .menu-category {
            padding: 25px;
        }
        
        .info-section {
            padding: 25px;
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
        
        .jumbotron {
            padding: 35px 20px;
            margin-bottom: 30px;
        }
        
        .jumbotron h1 {
            font-size: 2rem;
        }
        
        .jumbotron .lead {
            font-size: 1rem;
        }
        
        .menu-grid {
            grid-template-columns: 1fr;
            gap: 20px;
        }
        
        .menu-category {
            padding: 20px;
        }
        
        .info-section {
            padding: 20px;
        }
        
        .main-nav ul {
            flex-direction: column;
            gap: 10px;
        }
        
        .main-header .container {
            flex-direction: column;
            gap: 15px;
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
                <div class="jumbotron">
                    <h1>안녕하세요, ${user.userName}님!</h1>
                    <p class="lead">업무 능률 증진을 위한 웹사이트입니다.</p>
                </div>
                
                <!-- 메뉴 섹션 -->
                <div class="content-section">
                    <h2 class="section-title">
                        <i class="fas fa-th-large"></i>메뉴
                    </h2>
                    
                    <div class="menu-grid">
                        <c:forEach var="entry" items="${dashboardMenus}">
                            <div class="menu-category">
                                <h3 class="category-title">
                                    <i class="fas fa-th-large"></i>${entry.key}
                                </h3>
                                <ul class="menu-list">
                                    <c:forEach var="menuItem" items="${entry.value}">
                                        <li>
                                            <a href="${pageContext.request.contextPath}/${menuItem.url}">
                                                <i class="${menuItem.icon} mr-2"></i>${menuItem.title}
                                            </a>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                
                <!-- 정보 섹션 -->
                <div class="info-section">
                    <h3>
                        <i class="fas fa-info-circle"></i>레이아웃 테스트 정보
                    </h3>
                    <p>이 페이지는 모든 콘텐츠(헤더, 메인 콘텐츠, 푸터)를 1100px 영역 안에 배치하고 배경과 명확히 분리하는 레이아웃 테스트입니다.</p>
                    <ul>
                        <li>전체 콘텐츠 영역: 1100px 고정 너비</li>
                        <li>헤더, 메인 콘텐츠, 푸터 모두 포함</li>
                        <li>배경: 그라데이션 + 패턴 효과</li>
                        <li>반응형 디자인 지원</li>
                        <li>기존 헤더 디자인 적용</li>
                        <li>충분한 여백으로 가독성 개선</li>
                    </ul>
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
</body>
</html>