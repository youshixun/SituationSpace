function  [Xckf,P,v,Pzminus] = CKF_filtering_model(xhat,Pminus,R,xyz,Z)

%-------------------------------------------------------------------------%
%                               1. CKF initialization                     %
%-------------------------------------------------------------------------% 

    n=9;                                                              % 9ά
    m=2*n;                                                        % �ݻ�����
    w=1/m;                                                      % Ȩֵw=1/m
    kmn=zeros(m,n);

    for i=1:n
       kmn(i,i)=1;
       kmn(m+1-i,n+1-i)=-1;
    end
    
    kesi=sqrt(m/2)*kmn;
    
%-------------------------------------------------------------------------%
%         2. Cholesky decomposition and prediction of observation         %
%-------------------------------------------------------------------------%

    Sminus=chol(Pminus,'lower');
  
    for cpoint=1:m
        rjpoint(:,cpoint)=Sminus*kesi(cpoint,:)'+xhat;          % �����ݻ���
        vec(1:3,cpoint)=[rjpoint(1,cpoint);
                         rjpoint(4,cpoint);
                         rjpoint(7,cpoint)]-xyz;

        if vec(1,cpoint)>=0
            dem(cpoint)=0;
        else
            if vec(2,cpoint)>=0
                dem(cpoint)=1;
            else
                dem(cpoint)=-1;
            end  
        end

        Zt(:,cpoint)=[norm(vec(:,cpoint));...                   
                      atan((vec(2,cpoint))/(vec(1,cpoint)))+dem(cpoint)*pi;...
                      asin((vec(3,cpoint))/norm(vec(:,cpoint)))];
                  
%-------------------------------Restoration-------------------------------%
         if cpoint==4                                     % 4��13ָ��y���ֵ
             if Zt(2,cpoint)-Zt(2,cpoint-1)>pi   
                 Zt(2,cpoint)=Zt(2,cpoint)-2*pi;
             else
                 if Zt(2,cpoint)-Zt(2,cpoint-1)<-pi
                     Zt(2,cpoint)=Zt(2,cpoint)+2*pi;
                 end
             end
         else
             if cpoint==13
                  if Zt(2,cpoint)-Zt(2,cpoint-1)>pi   
                      Zt(2,cpoint)=Zt(2,cpoint)-2*pi;
                  else
                        if Zt(2,cpoint)-Zt(2,cpoint-1)<-pi
                            Zt(2,cpoint)=Zt(2,cpoint)+2*pi;
                        end
                   end
             end            
         end
%--------------------------- for quadrant jump ---------------------------%        
    end    

    zhat=w*sum(Zt,2);
    Pzminus=0;
    
    for cpoint=1:m
        Pzminus=Pzminus+w*Zt(:,cpoint)*Zt(:,cpoint)';
    end
    
    Pzminus=Pzminus-zhat*zhat'+R;
    Pxzminus=0;
    
    for cpoint=1:m
        Pxzminus=Pxzminus+w*rjpoint(:,cpoint)*Zt(:,cpoint)';
    end
    
    Pxzminus=Pxzminus-xhat*zhat';
    
%-------------------------------------------------------------------------%
%                               4. update                                 %
%-------------------------------------------------------------------------% 
    
    KI=Pxzminus/Pzminus;
    v=Z-zhat;                                                        % ��Ϣ
    xhat=xhat+KI*v;                                      % ״̬����-�����Ϣ
    P=Pminus-KI*Pzminus*KI';                            % ״̬Э����������
    Xckf=xhat;  
end