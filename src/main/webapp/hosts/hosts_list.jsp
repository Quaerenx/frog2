<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="호스트 관리" scope="request" />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main_style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/utilities.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/customers.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/dashboard_box.css">
    <style>
      .stat-badge{display:inline-flex;align-items:center;gap:6px;background:#f3f4f6;border:1px solid #e5e7eb;border-radius:8px;padding:6px 10px;color:#374151}
      .stat-badge i{color:#4b5563}
      /* 테이블 셀 내용 잘림 방지 및 레이아웃 안정화 */
      .page-hosts .customer-table{table-layout:fixed !important;width:100%;}
      .page-hosts .customer-table th,.page-hosts .customer-table td{
        overflow:visible !important;
        text-overflow:clip !important;
        white-space:normal !important;
        text-align:center; /* 중앙 정렬 */
        vertical-align:middle; /* 세로 중앙 정렬 */
      }
      /* 셀 내부 텍스트를 확실히 중앙정렬 */
      .page-hosts .customer-table td .cell-text{
        display:block;
        width:100%;
        text-align:center;
      }
      /* 편집 오버레이 입력을 위한 셀 상태 */
      .page-hosts .customer-table td.td-edit{position:relative}
      .page-hosts .customer-table td.td-edit .cell-text{opacity:0}
      .page-hosts .customer-table td.td-edit .edit-input{position:absolute;left:8px;right:8px;top:6px;bottom:6px;width:auto;min-width:0;height:auto;box-sizing:border-box}
      /* 클릭 가능한 행 스타일 */
      .clickable-row{cursor:pointer}
      .clickable-row:hover{background:#fafafa}
      /* 인라인 편집 컨트롤 */
      .edit-actions{display:flex;gap:6px;justify-content:flex-end;margin-top:6px}
      .edit-input{width:100%;min-width:0}
      @media (max-width: 900px){ .edit-input{min-width:80px} }

      /* 컬럼 너비 조정: IP, 사용자, 호스트 위치를 기존보다 좁게(대략 반으로) 설정 */
      .page-hosts .customer-table th:nth-child(1),
      .page-hosts .customer-table td:nth-child(1) {
        width:16%; /* IP 열 너비 추가 확대 */
        max-width:16%;
        min-width:120px;
        white-space:nowrap !important; /* IP는 한 줄 유지 */
        overflow:hidden; /* 넘침 숨김 */
        text-overflow:ellipsis; /* 말줄임표 */
      }
      .page-hosts .customer-table th:nth-child(2),
      .page-hosts .customer-table td:nth-child(2) {
        width:14%; /* 사용자 열 좁게 */
        max-width:14%;
        min-width:90px;
      }
      /* 목적(3열) 너비 축소 */
      .page-hosts .customer-table th:nth-child(3),
      .page-hosts .customer-table td:nth-child(3) {
        width:8%;
        max-width:8%;
        min-width:80px;
      }
      .page-hosts .customer-table th:nth-child(4),
      .page-hosts .customer-table td:nth-child(4) {
        width:14%; /* 호스트 위치 열 좁게 */
        max-width:14%;
        min-width:90px;
      }
      /* 비고(5열) 너비 명시적으로 지정하여 비정상적 확장 방지 */
      .page-hosts .customer-table th:nth-child(5),
      .page-hosts .customer-table td:nth-child(5) {
        width:16%;
        max-width:16%;
        min-width:90px;
      }

      /* 플로팅 편집 툴바: 편집 중인 행 옆에 표시 (JS에서 좌표 계산) */
      .edit-toolbar{position:fixed;display:flex;align-items:center;gap:8px;background:#fff;border:1px solid #e5e7eb;border-radius:10px;padding:10px 12px;box-shadow:0 6px 18px rgba(0,0,0,.12);z-index:9999}
      .edit-toolbar .ip{font-weight:700;color:#111827;margin-right:6px}
      .edit-toolbar .sep{width:1px;height:18px;background:#e5e7eb;margin:0 4px}
      @media (max-width: 600px){ .edit-toolbar{padding:8px 10px} }
    </style>
</head>
<body class="page-1050 page-hosts">
<%@ include file="/includes/header.jsp" %>

<div class="customer-management">
  <t:pageHeader>
    <jsp:attribute name="title">
      <i class="fas fa-network-wired"></i> ${pageTitle}
    </jsp:attribute>
    <jsp:attribute name="subtitle">
      관리 대역: <strong>192.168.40.0/24</strong>
      <span class="stat-badge" title="현재 할당된 IP 수"><i class="fas fa-hdd"></i>할당: <strong>${fn:length(hostMap)}</strong> / 254</span>
    </jsp:attribute>
  </t:pageHeader>

  <!-- 메시지 출력 -->
  <c:if test="${not empty sessionScope.message}">
      <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${sessionScope.message}</div>
      <c:remove var="message" scope="session" />
  </c:if>
  <c:if test="${not empty sessionScope.error}">
      <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${sessionScope.error}</div>
      <c:remove var="error" scope="session" />
  </c:if>

  <div class="table-container">
    <div class="table-wrapper table-responsive">
      <table class="customer-table">
        <thead>
          <tr>
            <th>IP</th>
            <th>사용자</th>
            <th>목적</th>
            <th>호스트 위치</th>
            <th>비고</th>
          </tr>
        </thead>
        <tbody id="hosts-body">
          <c:set var="base" value="192.168.40." />
          <c:forEach var="i" begin="1" end="254">
            <c:set var="ip" value="${base}${i}" />
            <c:set var="h" value="${hostMap[ip]}" />
            <tr class="clickable-row" data-ip="${ip}"
                data-user="${h != null && h.userName != null ? fn:escapeXml(h.userName) : ''}"
                data-purpose="${h != null && h.purpose != null ? fn:escapeXml(h.purpose) : ''}"
                data-location="${h != null && h.hostLocation != null ? fn:escapeXml(h.hostLocation) : ''}"
                data-note="${h != null && h.note != null ? fn:escapeXml(h.note) : ''}"
                data-color="${h != null && h.rowColor != null ? fn:escapeXml(h.rowColor) : ''}">
              <td>
                <strong>${ip}</strong>
                <form action="${pageContext.request.contextPath}/hosts" method="post" id="f-${i}" style="display:none"></form>
                <input type="hidden" name="ip" value="${ip}" form="f-${i}" />
              </td>
              <td><span class="cell-text">${h != null && h.userName != null ? h.userName : ''}</span></td>
              <td><span class="cell-text">${h != null && h.purpose != null ? h.purpose : ''}</span></td>
              <td><span class="cell-text">${h != null && h.hostLocation != null ? h.hostLocation : ''}</span></td>
              <td><span class="cell-text">${h != null && h.note != null ? h.note : ''}</span></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
  (function(){
    const $$ = (sel, ctx=document) => Array.from(ctx.querySelectorAll(sel));
    let editingRow = null;
    let toolbarEl = null;
    let unbindToolbarListeners = null;

    // 행 색상 적용 유틸리티 (서버 제공 값 기반)
    function applyRowColor(tr, color){
      const firstTd = tr.querySelector('td:first-child');
      if (!firstTd) return;
      if (color && /^#([0-9a-fA-F]{3}){1,2}$/.test(color)){
        firstTd.style.borderLeft = '6px solid ' + color;
      } else {
        firstTd.style.borderLeft = '';
      }
    }

    function createOverlayInput(td, name, value, formId){
      td.classList.add('td-edit');
      const input = document.createElement('input');
      input.type = 'text';
      input.className = 'edit-input';
      input.name = name;
      input.value = value;
      input.setAttribute('form', formId);
      td.appendChild(input);
      return input;
    }

    function toEditMode(tr){
      if (editingRow && editingRow !== tr){ cancelEdit(editingRow); }
      if (tr.dataset.editing === 'true') return;
      tr.dataset.orig = tr.innerHTML; // 원본 저장
      const ip = tr.dataset.ip;
      const formId = 'f-' + ip.split('.').pop();
      const user = tr.dataset.user || '';
      const purpose = tr.dataset.purpose || '';
      const location = tr.dataset.location || '';
      const note = tr.dataset.note || '';

      const tds = tr.children;
      // 0: IP + hidden form (유지)
      // 1~4: 입력칸을 기존 내용 위에 오버레이로 추가 (레이아웃 유지)
      const inps = [];
      inps.push(createOverlayInput(tds[1], 'user_name', user, formId));
      inps.push(createOverlayInput(tds[2], 'purpose', purpose, formId));
      inps.push(createOverlayInput(tds[3], 'host_location', location, formId));
      inps.push(createOverlayInput(tds[4], 'note', note, formId));

      // 키보드 단축키: Enter 저장, Esc 취소
      inps.forEach(inp => {
         inp.addEventListener('keydown', (e)=>{
           if (e.key === 'Enter') { e.preventDefault(); doSave(tr); }
           else if (e.key === 'Escape') { e.preventDefault(); cancelEdit(tr); }
         });
       });
      // 첫 입력에 포커스
      if (inps[0]) { inps[0].focus(); inps[0].select && inps[0].select(); }

      tr.dataset.editing = 'true';
      editingRow = tr;

      // 플로팅 툴바 표시
      showToolbar(formId, ip, tr);
    }

    function cancelEdit(tr){
      if (!tr || !tr.dataset.orig) return;
      tr.innerHTML = tr.dataset.orig;
      tr.dataset.editing = 'false';
      editingRow = null;
      bindRow(tr); // 이벤트 다시 바인딩
      hideToolbar();
    }

    function doDelete(tr){
      const ip = tr.dataset.ip;
      const formId = 'f-' + ip.split('.').pop();
      if (!confirm(ip + ' 삭제할까요?')) return;
      ensureHidden(formId, 'action', 'delete');
      document.getElementById(formId).submit();
    }

    function doSave(tr){
      const ip = tr.dataset.ip;
      const formId = 'f-' + ip.split('.').pop();
      // 저장 직전에 툴바의 현재 색상값을 강제로 반영 (이벤트 미발생 대비)
      const colorEl = document.querySelector('.edit-toolbar [data-role="color"]');
      if (colorEl){
        const val = colorEl.value || '';
        ensureHidden(formId, 'row_color', val);
        tr.dataset.color = val;
      }
      ensureHidden(formId, 'action', 'save');
      document.getElementById(formId).submit();
    }

    function ensureHidden(formId, name, value){
        const form = document.getElementById(formId);
        if (!form) {
          // 폼을 찾지 못한 경우 기존 방식으로 최소한 값만 설정
          let el = document.querySelector(`input[name="${name}"][form="${formId}"]`);
          if (!el) {
            el = document.createElement('input');
            el.type = 'hidden';
            el.name = name;
            el.setAttribute('form', formId);
            document.body.appendChild(el);
          }
          el.value = value;
          return;
        }
        // 폼 내부 우선 탐색
        let el = form.querySelector(`input[name="${name}"]`);
        if (!el) {
          // 폼 바깥에 form= 으로 연결된 기존 요소가 있다면 재사용하되 폼 안으로 이동시킴
          const externals = Array.from(document.querySelectorAll(`input[name="${name}"][form="${formId}"]`));
          if (externals.length > 0) {
            el = externals[0];
            // 중복 제거: 나머지는 제거
            externals.slice(1).forEach(x => x.remove());
            // 폼 내부로 이동 (form 속성은 유지/무관)
            form.appendChild(el);
          }
        }
        if (!el) {
          el = document.createElement('input');
          el.type = 'hidden';
          el.name = name;
          // form 내부에 직접 추가
          form.appendChild(el);
        }
        // 동일 name + formId 로 바깥에 남아있는 중복 제거
        Array.from(document.querySelectorAll(`input[name="${name}"][form="${formId}"]`))
          .filter(x => x !== el)
          .forEach(x => x.remove());
        el.value = value;
      }

    function escapeHtml(s){
      return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }

    function positionToolbarNextToRow(tr){
      if (!toolbarEl) return;
      const rect = tr.getBoundingClientRect();
      const tbRect = toolbarEl.getBoundingClientRect();
      const margin = 8;
      // 기본: 행 오른쪽 옆
      let left = rect.right + margin;
      // 화면 오른쪽을 넘으면 행 왼쪽 옆에 배치
      if (left + tbRect.width > window.innerWidth - margin){
        left = Math.max(margin, rect.left - tbRect.width - margin);
      }
      // 수직 중앙 정렬, 화면 경계 보정
      let top = rect.top + (rect.height - tbRect.height)/2;
      top = Math.max(margin, Math.min(top, window.innerHeight - tbRect.height - margin));
      toolbarEl.style.left = left + 'px';
      toolbarEl.style.top = top + 'px';
    }

    function showToolbar(formId, ip, tr){
      if (!toolbarEl){
        toolbarEl = document.createElement('div');
        toolbarEl.className = 'edit-toolbar';
        document.body.appendChild(toolbarEl);
        // 툴바 클릭은 행 클릭으로 전파되지 않도록 처리
        toolbarEl.addEventListener('click', e => e.stopPropagation());
      }
      const currentColor = tr.dataset.color || '';
      // 사용자 변경 여부 플래그 초기화
      toolbarEl.dataset.touched = '0';
      toolbarEl.dataset.formId = formId;
      toolbarEl.innerHTML = '<span class="ip">' + escapeHtml(ip) + '</span>' +
        '<span class="sep"></span>' +
        '<label style="font-size:12px;color:#6b7280;margin-right:4px">색상</label>' +
        '<input type="color" data-role="color" aria-label="행 색상" />' +
        '<button type="button" class="btn btn-light btn-sm" data-role="clear-color" title="색상 지우기">지우기</button>' +
        '<span class="sep"></span>' +
        '<button type="button" class="btn btn-primary btn-sm" data-role="save">저장</button>' +
        '<button type="button" class="btn btn-danger btn-sm" data-role="delete">삭제</button>' +
        '<button type="button" class="btn btn-secondary btn-sm" data-role="cancel">취소</button>';
      // 핸들러 바인딩
      toolbarEl.querySelector('[data-role="save"]').onclick = (e)=>{ e.stopPropagation(); doSave(tr); };
      toolbarEl.querySelector('[data-role="delete"]').onclick = (e)=>{ e.stopPropagation(); doDelete(tr); };
      toolbarEl.querySelector('[data-role="cancel"]').onclick = (e)=>{ e.stopPropagation(); cancelEdit(tr); };
      const colorInput = toolbarEl.querySelector('[data-role="color"]');
      colorInput.value = currentColor || '#ffffff';
      // 변경이 없으면 현재 색상만 제출되도록 hidden을 현재값으로 설정(빈 경우 빈 값)
      ensureHidden(formId, 'row_color', currentColor || '');
      const onColor = (e)=>{
        const c = e.target.value || '';
        applyRowColor(tr, c);
        tr.dataset.color = c;
        ensureHidden(formId, 'row_color', c);
        toolbarEl.dataset.touched = '1';
      };
      colorInput.addEventListener('input', onColor);
      colorInput.addEventListener('change', onColor);
      toolbarEl.querySelector('[data-role="clear-color"]').onclick = (e)=>{
        e.stopPropagation();
        applyRowColor(tr, null);
        tr.dataset.color = '';
        ensureHidden(formId, 'row_color', '');
        colorInput.value = '#ffffff';
        toolbarEl.dataset.touched = '1';
      };

      // 즉시 위치 지정
      toolbarEl.style.left = '-9999px';
      toolbarEl.style.top = '-9999px';
      requestAnimationFrame(() => positionToolbarNextToRow(tr));

      // 스크롤/리사이즈 시 위치 갱신
      const reposition = () => positionToolbarNextToRow(tr);
      const wrapper = document.querySelector('.table-wrapper');
      window.addEventListener('scroll', reposition, { passive:true });
      window.addEventListener('resize', reposition);
      if (wrapper) wrapper.addEventListener('scroll', reposition, { passive:true });
      unbindToolbarListeners = () => {
        window.removeEventListener('scroll', reposition);
        window.removeEventListener('resize', reposition);
        if (wrapper) wrapper.removeEventListener('scroll', reposition);
        unbindToolbarListeners = null;
      };
    }

    function hideToolbar(){
      if (unbindToolbarListeners) unbindToolbarListeners();
      if (toolbarEl){ toolbarEl.remove(); toolbarEl = null; }
    }

    function bindRow(tr){
      tr.addEventListener('click', function(e){
        // 이미 버튼/입력 클릭은 무시
        const tag = e.target.tagName.toLowerCase();
        if (tag === 'button' || tag === 'input' || tag === 'select' || tag === 'textarea') return;
        toEditMode(tr);
      });
    }

    // 초기 바인딩 및 데이터 셋업
    $$('#hosts-body tr').forEach(tr => {
      // ip는 이미 data-ip 존재, 나머지는 서버에서 data-*로 주입됨
      bindRow(tr);
      // 서버 제공 색상 적용
      const c = tr.dataset.color;
      if (c) applyRowColor(tr, c);
    });
  })();
</script>

</body>
</html>
