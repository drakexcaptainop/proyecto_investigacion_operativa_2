%%
D = ["15:03"	"15:04"	"15:20"
"15:16"	"15:21"	"15:27"
"15:25"	"15:26"	"15:38"
"15:35"	"15:37"	"15:49"
"15:50"	"15:50"	 "16:00"
"16:01"	"16:02"	"16:13"
"16:10"	"16:12"	"16:28"
"16:20"	"16:26"	"16:35"
"16:25"	"16:36"	"16:43"
"16:37"	"16:44"	"16:52"
"16:49"	"16:54"	"17:01"
"16:55"	"17:02"	"17:09"
"17:05"	"17:10"	"17:15"
"17:11"	"17:15"	"17:20"
"17:15"	"17:21"	"17:30"
"17:28"	"17:31"	"17:42"
"17:40"	"17:42"	"17:52"
"17:55"	"17:55"	"18:03"
"18:00"	"18:08"	"18:20"];

time = duration( D,"Format","hh:mm" );
mins = minutes(time);

mu_llegadas = mean( [0;diff(mins(:, 1))] )
std_llegadas = std( [0;diff(mins(:, 1))] )


mu_servicio = mean(mins( :, 3 ) - mins(:, 2))
std_servicio = std( mins( :, 3 ) - mins(:, 2) )

%%


NS = 500;
NC = 40;
lambda = 0.061;
mu = 0.102;



W = []; Wq = []; Pw = []; To = [];
for i=1:NS
    res = run_sim2( mu_servicio, std_servicio, mu_llegadas, std_llegadas, NC, false );
    W = [W, res.W];
    Wq = [Wq, res.Wq];
    Pw = [Pw, res.Pw];
    To = [To, res.To];
end
%%
%subplot(411)
histogram(W, 'FaceColor','r')
[mean(W), max(W), min(W)]
%subplot(412)
histogram(Wq, FaceColor='g')
[mean(Wq), max(Wq), min(Wq)]
subplot(413)
histogram(Pw, FaceColor='k')
[mean(Pw), max(Pw), min(Pw)]
subplot(414)
histogram(To, FaceColor="#D95319")
[mean(To), max(To), min(To)]


mm = @( x )[min(x), max(x)];

mm(W)


%%
function res = run_sim(lambda, mu, N, hplot)
T= 0;
muestra_t_llegadas = rand( N, 1 ) * 5;
muestra_t_atencion = randn(  );

tiempo_llegada = 0;
tiempo_finalizacion = 0;
t_fin = 0;



t_espera = []; t_sistema = []; t_ocio=[];
for i=1:N
    muestra_t_atencion = expinv( rand, 1/mu );
    muestra_t_llegada = expinv( rand, 1/lambda );
    tiempo_llegada = tiempo_llegada + muestra_t_llegada;
    if tiempo_llegada > tiempo_finalizacion
        t_inicio = tiempo_llegada;
    else
        t_inicio = tiempo_finalizacion;
    end
    t_ocio = [t_ocio t_inicio-tiempo_finalizacion];
    tiempo_espera = t_inicio - tiempo_llegada;
    tiempo_finalizacion = t_inicio + muestra_t_atencion;
    t_sistema = [t_sistema tiempo_finalizacion - tiempo_llegada];
    t_espera = [t_espera t_inicio - tiempo_llegada];
    
end

if nargin == 4 && hplot
subplot(131)
hist(t_espera); title('tiempo de espera')
subplot(132)
hist(t_sistema); title('tiempo en sistema')
subplot(133)
hist(t_ocio)
title('tiempo de ocio')

end


res = table( mean(t_espera), mean(t_sistema), sum(t_espera>0)./N, mean(t_ocio),VariableNames=["Wq", "W", "Pw", "To"] );
end


%%
function res = run_sim2(mu_servicio, std_servicio, mu_llegadas, std_llegadas, N, hplot)
T= 0;


tiempo_llegada = 0;
tiempo_finalizacion = 0;
t_fin = 0;



t_espera = []; t_sistema = []; t_ocio=[];
for i=1:N
    muestra_t_atencion = norminv( rand, mu_servicio, std_servicio  )
    muestra_t_llegada = norminv( rand, mu_llegadas, std_llegadas)
    tiempo_llegada = tiempo_llegada + muestra_t_llegada;
    if tiempo_llegada > tiempo_finalizacion
        t_inicio = tiempo_llegada;
    else
        t_inicio = tiempo_finalizacion;
    end
    t_ocio = [t_ocio t_inicio-tiempo_finalizacion];
    tiempo_espera = t_inicio - tiempo_llegada;
    tiempo_finalizacion = t_inicio + muestra_t_atencion;
    t_sistema = [t_sistema tiempo_finalizacion - tiempo_llegada];
    t_espera = [t_espera t_inicio - tiempo_llegada];
    
end

if nargin == 4 && hplot
subplot(131)
hist(t_espera); title('tiempo de espera')
subplot(132)
hist(t_sistema); title('tiempo en sistema')
subplot(133)
hist(t_ocio)
title('tiempo de ocio')

end


res = table( mean(t_espera), mean(t_sistema), sum(t_espera>0)./N, mean(t_ocio),VariableNames=["Wq", "W", "Pw", "To"] );
end