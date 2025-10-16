<%@ page isErrorPage="true" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>서버 오류 (500)</title>
  <style>body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;margin:40px;color:#333} .card{max-width:720px;margin:auto;padding:24px;border:1px solid #eee;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.04)} h1{font-size:22px;margin:0 0 12px} pre{background:#f8f8f8;padding:12px;overflow:auto;border-radius:6px}</style>
</head>
<body>
  <div class="card">
    <h1>처리 중 문제가 발생했습니다.</h1>
    <p>잠시 후 다시 시도해 주세요. 문제가 지속되면 관리자에게 문의하세요.</p>
    <details>
      <summary>자세한 오류 정보</summary>
      <pre><%= exception == null ? "" : exception.getMessage() %></pre>
    </details>
    <p><a href="<%= request.getContextPath() %>/dashboard">대시보드로 이동</a></p>
  </div>
</body>
</html>
