package repository

import (
	"context"

	"gorm.io/gorm"

	model "myanmar-property/backend/12-client-service"
)

type ClientRepository interface {
	Create(ctx context.Context, client *model.Client) error
	GetByID(ctx context.Context, id, agentID int64) (*model.Client, error)
	List(ctx context.Context, agentID int64, status string, search string, page, pageSize int) ([]*model.Client, int64, error)
	Update(ctx context.Context, client *model.Client) error
	Delete(ctx context.Context, id, agentID int64) error
	AddFollowUp(ctx context.Context, record *model.FollowUpRecord) error
	GetFollowUps(ctx context.Context, clientID int64, page, pageSize int) ([]*model.FollowUpRecord, int64, error)
}

type clientRepository struct {
	db *gorm.DB
}

func NewClientRepository(db *gorm.DB) ClientRepository {
	return &clientRepository{db: db}
}

func (r *clientRepository) Create(ctx context.Context, client *model.Client) error {
	return r.db.WithContext(ctx).Create(client).Error
}

func (r *clientRepository) GetByID(ctx context.Context, id, agentID int64) (*model.Client, error) {
	var client model.Client
	err := r.db.WithContext(ctx).Where("id = ? AND owner_id = ?", id, agentID).First(&client).Error
	if err != nil {
		return nil, err
	}
	return &client, nil
}

func (r *clientRepository) List(ctx context.Context, agentID int64, status, search string, page, pageSize int) ([]*model.Client, int64, error) {
	query := r.db.WithContext(ctx).Where("owner_id = ?", agentID)
	if status != "" {
		query = query.Where("status = ?", status)
	}
	if search != "" {
		query = query.Where("name LIKE ? OR phone LIKE ?", "%"+search+"%", "%"+search+"%")
	}
	var total int64
	query.Model(&model.Client{}).Count(&total)
	var clients []*model.Client
	offset := (page - 1) * pageSize
	err := query.Order("updated_at DESC").Offset(offset).Limit(pageSize).Find(&clients).Error
	return clients, total, err
}

func (r *clientRepository) Update(ctx context.Context, client *model.Client) error {
	return r.db.WithContext(ctx).Save(client).Error
}

func (r *clientRepository) Delete(ctx context.Context, id, agentID int64) error {
	return r.db.WithContext(ctx).Where("id = ? AND owner_id = ?", id, agentID).Delete(&model.Client{}).Error
}

func (r *clientRepository) AddFollowUp(ctx context.Context, record *model.FollowUpRecord) error {
	return r.db.WithContext(ctx).Create(record).Error
}

func (r *clientRepository) GetFollowUps(ctx context.Context, clientID int64, page, pageSize int) ([]*model.FollowUpRecord, int64, error) {
	var total int64
	r.db.WithContext(ctx).Model(&model.FollowUpRecord{}).Where("client_id = ?", clientID).Count(&total)
	var records []*model.FollowUpRecord
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).Where("client_id = ?", clientID).Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&records).Error
	return records, total, err
}
