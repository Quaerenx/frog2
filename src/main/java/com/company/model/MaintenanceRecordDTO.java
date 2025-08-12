package com.company.model;

import java.sql.Date;
import java.sql.Timestamp;

public class MaintenanceRecordDTO {
    private Long maintenanceId;
    private String customerName;
    private String inspectorName;
    private Date inspectionDate;
    private String verticaVersion;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // 기본 생성자
    public MaintenanceRecordDTO() {}

    // 게터와 세터 메소드
    public Long getMaintenanceId() {
        return maintenanceId;
    }

    public void setMaintenanceId(Long maintenanceId) {
        this.maintenanceId = maintenanceId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getInspectorName() {
        return inspectorName;
    }

    public void setInspectorName(String inspectorName) {
        this.inspectorName = inspectorName;
    }

    public Date getInspectionDate() {
        return inspectionDate;
    }

    public void setInspectionDate(Date inspectionDate) {
        this.inspectionDate = inspectionDate;
    }

    public String getVerticaVersion() {
        return verticaVersion;
    }

    public void setVerticaVersion(String verticaVersion) {
        this.verticaVersion = verticaVersion;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}