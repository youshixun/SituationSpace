function [Xn_nl]=IMM_prediction(F,Q,Xn_est,Pn_est,u,n_o)
    model=size(u,2);
    Pr=[0.8,0.1,0.1;
        0.1,0.8,0.1;
        0.1,0.1,0.8];      %转移概率矩阵 
    c_mean=zeros(1,model); %归一化常数
    mu=zeros(model,model);
    
    for i=1:model
        c_mean=c_mean+Pr(i,:)*u(i);
    end
    
    for i=1:model          %贝叶斯转移概率
        mu(i,:)=Pr(i,:)*u(i)./c_mean;
    end
    
    for j=1:model
        X0{j,1}=zeros(9,1);
        P0{j,1}=zeros(9);
        for i=1:model      %混合状态估计
            X0{j,1}=X0{j,1}+Xn_est{i,n_o}*mu(i,j);
        end
        for i=1:model      %混合协方差估计
            P0{j,1}=P0{j,1}+mu(i,j)*( Pn_est{i,n_o}...
                    +(Xn_est{i,n_o}-X0{j,1})*(Xn_est{i,n_o}-X0{j,1})');
        end
    end
                           
    Xn_nl=zeros(9,1);      %各自通道的预测输出
    
    for j=1:model          
        [Xn_n{j,1},Pminus]=CKF_prediction_model(F{j,n_o},Q{j,n_o},X0{j,1},P0{j,1});
        Xn_nl=Xn_nl+Xn_n{j,1}.*u(j);
    end
end

