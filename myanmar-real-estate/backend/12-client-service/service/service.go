package service

import (
	"context"
	"time"

	"myanmar-property/backend/07-common"
	model "myanmar-property/backend/12-client-service"
	"myanmar-property/backend/12-client-service/repository"
)

type ClientService interface {
	CreateClient(ctx context.Context, agentID int64, req *CreateClientRequest) (*model.Client, error)
	GetClients(ctx context.Context, agentID int64, status, search string, page, pageSize int) ([]*model.Client, int64, error)
	GetClient(ctx context.Context, clientID, agentID int64) (*model.Client, error)
	UpdateClient(ctx context.Context, clientID, agentID int64, req *UpdateClientRequest) error
	DeleteClient(ctx context.Context, clientID, agentID int64) error
	AddFollowUp(ctx context.Context, clientID, agentID int64, req *AddFollowUpRequest) error
	GetFollowUps(ctx context.Context, clientID, agentID int64, page, pageSize int) ([]*model.FollowUpRecord, int64, error)
}

type CreateClientRequest struct {
	Name        string `json:"name" binding:"required"`
	Phone       string `json:"phone"`
	Source      string `json:"source"`
	Budget      int64  `json:"budget"`
	BudgetMax   int64  `json:"budget_max"`
	Requirement string `json:"requirement"`
	PreferArea  string `json:"prefer_area"`
	HouseType   string `json:"house_type"`
	Tags        string `json:"tags"`
	Remark      string `json:"remark"`
}

type UpdateClientRequest struct {
	Name         string     `json:"name"`
	Phone        string     `json:"phone"`
	Status       string     `json:"status"`
	Budget       int64      `json:"budget"`
	BudgetMax    int64      `json:"budget_max"`
	Requirement  string     `json:"requirement"`
	PreferArea   string     `json:"prefer_area"`
	HouseType    string     `json:"house_type"`
	Tags         string     `json:"tags"`
	NextFollowAt *time.Time `json:"next_follow_at"`
	Remark       string     `json:"remark"`
}

type AddFollowUpRequest struct {
	ContactMethod string     `json:"contact_method" binding:"required"`
	Content       string     `json:"content" binding:"required"`
	StatusChange  string     `json:"status_change"`
	NextFollowAt  *time.Time `json:"next_follow_at"`
}

type clientService struct {
	repo   repository.ClientRepository
	config *common.Config
}

func NewClientService(repo repository.ClientRepository, config *common.Config) ClientService {
	return &clientService{repo: repo, config: config}
}

func (s *clientService) CreateClient(ctx context.Context, agentID int64, req *CreateClientRequest) (*model.Client, error) {
	client := &model.Client{
		AgentID:     agentID,
		Name:        req.Name,
		Phone:       req.Phone,
		Source:      req.Source,
		Status:      model.ClientStatusNew,
		Budget:      req.Budget,
		BudgetMax:   req.BudgetMax,
		Requirement: req.Requirement,
		PreferArea:  req.PreferArea,
		HouseType:   req.HouseType,
		Tags:        req.Tags,
		Remark:      req.Remark,
	}
	if err := s.repo.Create(ctx, client); err != nil {
		return nil, err
	}
	return client, nil
}

func (s *clientService) GetClients(ctx context.Context, agentID int64, status, search string, page, pageSize int) ([]*model.Client, int64, error) {
	return s.repo.List(ctx, agentID, status, search, page, pageSize)
}

func (s *clientService) GetClient(ctx context.Context, clientID, agentID int64) (*model.Client, error) {
	return s.repo.GetByID(ctx, clientID, agentID)
}

func (s *clientService) UpdateClient(ctx context.Context, clientID, agentID int64, req *UpdateClientRequest) error {
	client, err := s.repo.GetByID(ctx, clientID, agentID)
	if err != nil {
		return common.NewError(common.ErrCodeNotFound)
	}
	if req.Name != "" {
		client.Name = req.Name
	}
	if req.Phone != "" {
		client.Phone = req.Phone
	}
	if req.Status != "" {
		client.Status = req.Status
	}
	if req.Budget > 0 {
		client.Budget = req.Budget
	}
	if req.BudgetMax > 0 {
		client.BudgetMax = req.BudgetMax
	}
	if req.Requirement != "" {
		client.Requirement = req.Requirement
	}
	if req.PreferArea != "" {
		client.PreferArea = req.PreferArea
	}
	if req.HouseType != "" {
		client.HouseType = req.HouseType
	}
	if req.Tags != "" {
		client.Tags = req.Tags
	}
	if req.NextFollowAt != nil {
		client.NextFollowAt = req.NextFollowAt
	}
	if req.Remark != "" {
		client.Remark = req.Remark
	}
	return s.repo.Update(ctx, client)
}

func (s *clientService) DeleteClient(ctx context.Context, clientID, agentID int64) error {
	return s.repo.Delete(ctx, clientID, agentID)
}

func (s *clientService) AddFollowUp(ctx context.Context, clientID, agentID int64, req *AddFollowUpRequest) error {
	now := time.Now()
	record := &model.FollowUpRecord{
		ClientID:      clientID,
		AgentID:       agentID,
		ContactMethod: req.ContactMethod,
		Content:       req.Content,
		StatusChange:  req.StatusChange,
		NextFollowAt:  req.NextFollowAt,
	}
	if err := s.repo.AddFollowUp(ctx, record); err != nil {
		return err
	}
	// Update client's last follow-up time
	client, err := s.repo.GetByID(ctx, clientID, agentID)
	if err == nil {
		client.LastFollowAt = &now
		if req.StatusChange != "" {
			client.Status = req.StatusChange
		}
		if req.NextFollowAt != nil {
			client.NextFollowAt = req.NextFollowAt
		}
		s.repo.Update(ctx, client)
	}
	return nil
}

func (s *clientService) GetFollowUps(ctx context.Context, clientID, agentID int64, page, pageSize int) ([]*model.FollowUpRecord, int64, error) {
	// Verify ownership first
	if _, err := s.repo.GetByID(ctx, clientID, agentID); err != nil {
		return nil, 0, common.NewError(common.ErrCodeNotFound)
	}
	return s.repo.GetFollowUps(ctx, clientID, page, pageSize)
}
