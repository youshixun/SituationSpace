function [abt]=Collision(dvt,rx,LOS,vut,bl) 
    global T Num_objects C a_max

%-------------------------------------------------------------------------%
%                           1. threat judgment                            %
%-------------------------------------------------------------------------%

    strategy=zeros(1,Num_objects);
    
    for n_o=1:Num_objects
        angle_cone(n_o)=asin(rx(n_o)/dvt(n_o));                    %��в׶��
        angle_vut(n_o)=Modified_acos(vut(:,n_o)'*LOS(:,n_o)/...
                                    norm(vut(:,n_o)));     
        co(n_o)=sign((dvt(n_o)-rx(n_o)))*((dvt(n_o)-rx(n_o))/bl/rx(n_o));
        if co(n_o)>0
            if angle_cone(n_o)>=angle_vut(n_o) 
                strategy(n_o)=1;                               %��̬��׶����
            end   
        else
            strategy(n_o)=2;                                     %��̬������
        end
    end
    
%-------------------------------------------------------------------------%
%                          2. collision avoidance                         %
%-------------------------------------------------------------------------%    

    abt=zeros(3,1);
    
    for n_o=1:Num_objects
        bs(:,n_o)=zeros(3,1);
        if n_o==1                                                   
            if strategy(n_o)==2
                as1=2*(dvt(n_o)-rx(n_o)-vut(:,n_o)'*LOS(:,n_o)*T)/(T^2)*LOS(:,n_o);
                as2=-(vut(:,n_o)-vut(:,n_o)'*LOS(:,n_o)*LOS(:,n_o))/T;
                as=as1+as2;             
                bs(:,n_o)=C*as;                                            
                das_cb=Constraint_boundary(bs(:,n_o)/norm(bs(:,n_o)),a_max);         
                if norm(bs(:,n_o))>norm(das_cb)  
                     bs(:,n_o)=das_cb;
                end
            end
        else
            if strategy(n_o)==1
                ve(:,n_o)=vut(:,n_o)-vut(:,n_o)'...
                                     *LOS(:,n_o)*LOS(:,n_o);     %v��p,kʸ��
                if norm(ve(:,n_o))==0
                    ve(:,n_o)=[-LOS(2,n_o);LOS(1,n_o);0];
                end 
                aec=(vut(:,n_o)'*LOS(:,n_o)/norm(ve(:,n_o))...
                                *tan(angle_cone(n_o))-1)/T*ve(:,n_o);
                aec=C*aec;    
                am_cb=Constraint_boundary(aec/norm(aec),a_max);
                
                if norm(aec)>norm(am_cb)
                    aec=am_cb;
                end
                bs(:,n_o)=aec;                                     
            end
            if strategy(n_o)==2
                as1=2*(dvt(n_o)-rx(n_o)-vut(:,n_o)'*LOS(:,n_o)*T)/(T^2)*LOS(:,n_o);
                as2=-(vut(:,n_o)-vut(:,n_o)'*LOS(:,n_o)*LOS(:,n_o))/T;
                as=as1+as2;             
                bs(:,n_o)=C*as;                                         
                das_cb=Constraint_boundary(bs(:,n_o)/norm(bs(:,n_o)),a_max);          
                if norm(bs(:,n_o))>norm(das_cb)
                     bs(:,n_o)=das_cb;
                end
            end
        end
        abt=abt+bs(:,n_o);                                             
    end
    
%-------------------------------------------------------------------------%
%                       4. projection transformation                      %
%-------------------------------------------------------------------------%    
    
    abt=C'*abt;
end