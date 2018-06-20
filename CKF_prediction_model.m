function [xhat,Pminus] = CKF_prediction_model(F,Q,X0,P)

%-------------------------------------------------------------------------%
%                               1. CKF initialization                     %
%-------------------------------------------------------------------------% 
    n=9;                                                              % 9维
    m=2*n;                                                        % 容积点数
    w=1/m;                                                      % 权值w=1/m
    kmn=zeros(m,n);
    
    for i=1:n
       kmn(i,i)=1;
       kmn(m+1-i,n+1-i)=-1;
    end
    
    kesi=sqrt(m/2)*kmn;
    
%-------------------------------------------------------------------------%
%         2. Cholesky decomposition and prediction of observation         %
%-------------------------------------------------------------------------%

    Shat=chol(P,'lower');
    
    for cpoint=1:m
        rjpoint(:,cpoint)=Shat*kesi(cpoint,:)'+X0;              % 计算容积点
        Xminus(:,cpoint)= F*rjpoint(:,cpoint);                  % 传播容积点
    end
    
    xhat=w*sum(Xminus,2); 
    Pminus=0;
    
    for cpoint=1:m
        Pminus=Pminus+w*Xminus(:,cpoint)*Xminus(:,cpoint)';
    end
    
    Pminus=Pminus-xhat*xhat'+Q;
end

