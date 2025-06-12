# frozen_string_literal: true

module ActiveAct
  class ActionExecutionsController < ActionController::Base
    layout "active_act_admin"

    # Protege a interface: só acessível em ambiente de desenvolvimento
    before_action :restrict_to_dev

    # Listagem de execuções, com filtros
    def index
      @executions = ActiveAct::ActionExecution.order(created_at: :desc).limit(50)
    end

    # Detalhe de uma execução
    def show
      @execution = ActiveAct::ActionExecution.find(params[:id])
    end

    # Replay de uma execução
    def replay
      @execution = ActiveAct::ActionExecution.find(params[:id])
      # Lógica de replay a ser implementada
      redirect_to action_execution_path(@execution), notice: "Replay iniciado."
    end

    private

    def restrict_to_dev
      head :forbidden unless Rails.env.development?
    end
  end
end
