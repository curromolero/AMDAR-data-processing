% Conecta a la pagina web y se descarga el fichero
% webpage = 'https://dap.ceda.ac.uk/badc/ukmo-metdb/data/amdars/2020/01/ukmo-metdb_amdars_20200101.csv';
% webpage = 'https://dap.ceda.ac.uk/badc/ukmo-metdb/data/amdars/2021/04/ukmo-metdb_amdars_20210401.csv?download=1';
% webpage = 'https://es.mathworks.com/matlabcentral/fileexchange/';
% S = webread(webpage); 

% options = weboptions('Username','fmolero','Password','Repetir123!');
% str = urlwrite(webpage, 'ukmo-metdb_amdars_20200101.csv');
% str = webwrite(webpage, 'ukmo-metdb_amdars_20200101.csv');

% No funciona la conexion, se hace con Filezilla
idxResumen = 1;
resumen = struct('Dia', '', 'Hora', '', 'numAltitudes', 0, 'numPerfiles', 0);
% Lee los ficheros AMDAR, saca los de Madrid y lo guarda en CSV
directorio = '\\cendat2\lidar\CEDA archive AMDAR files\01';
fileList = getAllFiles(directorio, 'ukmo-metdb_amdars_*.*');
% fileList = getAllFiles(pwd, 'ukmo-metdb_amdars_*.*');
for i = 1:numel(fileList)
    % Lee linea a linea las primeras 200, identificando las variables
    % y los atributos globales
    fid1 = fopen(fileList{i},'r'); % open csv file for reading
    for lineaactual = 1:200
        line = fgets(fid1); % read line by line
        if strfind(line, 'data') % A partir de esta linea son datos
            lineaDatos = lineaactual;
        end %if 
    end
    fclose(fid1);
    Nrows = numel(textread(fileList{i},'%1c%*[^\n]'));
    rangoDatos = ['A' num2str(lineaDatos + 2) ':AI' num2str(Nrows)];
    datos = readtable(fileList{i}, 'Range', rangoDatos);
    
    % Elimina los casos malos -999999 en segundos (Var6)
    datos.Var6(datos.Var6 == -9999999) = nan;

    % Representa casos
    % geoscatter(datos.Var14(185:end), datos.Var15(185:end))
    geoscatter(datos.Var14, datos.Var15) % Si se lee el rango, no hay que usar indices
    geolimits([35 45],[-8 2])
    geobasemap streets

    % Extrae los ascensos/descensos sobre Madrid por latitud/longitud y 
    % alturas menores a 6 km
    idxMadrid = datos.Var14 >= 40 & datos.Var14 < 41 & ...
        datos.Var15 > -4 & datos.Var15 <= -3 & datos.Var16 < 6000;
    geoscatter(datos.Var14(idxMadrid), datos.Var15(idxMadrid));

    fechas = datenum(datos.Var1, datos.Var2, datos.Var3, ...
        datos.Var4, datos.Var5, datos.Var6);    
    plot(fechas(idxMadrid), datos.Var16(idxMadrid), '.')
    numIdxMadrid = find(idxMadrid);
    arrayIndices = NaN(50, 50); % Maximo de 50 perfiles/Dia y 50 puntos/perfil
    quePerfil = 1;
    idxPerfil = 1;
    for i = 1:length(numIdxMadrid)
        if i == length(numIdxMadrid)
            if numIdxMadrid(i) - numIdxMadrid(i-1) < 1000 % Indice no varia mas de 1000. Deberia ser 1, pero a veces son 300 o 700 indices
                arrayIndices(idxPerfil, quePerfil) = numIdxMadrid(i);
                idxPerfil = idxPerfil + 1; % Avanza una linea
            else
                quePerfil = quePerfil + 1; % Siguiente columna
                idxPerfil = 1; % Vuelva al principio de linea
            end %if
        else
            if numIdxMadrid(i+1) - numIdxMadrid(i) < 1000 % Indice no varia mas de 1000. Deberia ser 1, pero a veces son 300 o 700 indices
                arrayIndices(idxPerfil, quePerfil) = numIdxMadrid(i);
                idxPerfil = idxPerfil + 1; % Avanza una linea
            else
                quePerfil = quePerfil + 1; % Siguiente columna
                idxPerfil = 1; % Vuelva al principio de linea
            end %if
        end %if
    end %for
    % Reorganiza el array de salida con los datos relevantes
    perfiles = arrayIndices(:,~all(isnan(arrayIndices)));
    dimPerfiles = size(perfiles);
    for k = 1:dimPerfiles(2)
        idxPerfil = perfiles(~isnan(perfiles(:, k)), k);
        % Comprobar que el ascenso/descenso es correcto
        % Todas las etiquetas de Var12 y Var13 deben ser iguales, si es el
        % mismo avión
        if ~isequal(datos.Var12{idxPerfil},datos.Var12{idxPerfil(1)})
            idxCorrectos = strcmp(datos.Var12(idxPerfil), datos.Var12{idxPerfil(1)}); % Asume que el primer indice tiene el valor correcto de avion
            idxPerfil = idxPerfil(idxCorrectos);
        end %if
        if length(idxPerfil) < 3 % Perfil muy corto, descartar
            continue;
            % Las altitudes deben estar entre 0 y 6 km.
        elseif min(datos.Var16(idxPerfil)) < 0 || max(datos.Var16(idxPerfil)) > 6000
            errordlg('Las altitudes del perfil son extrañas');
            continue;
            % El ascenso/descenso no debe durar mas de 15 minutos
        elseif (max(fechas(idxPerfil)) - min(fechas(idxPerfil))) > 15/(24*60)
            errordlg('El ascenso/descenso dura mas de 10 minutos');
            continue;
        else
            arrayPerfil = NaN(length(idxPerfil), 7);
            % Ordena el array por alturas, a veces viene en triadas
            % invertidas
            [AltitudOrdenanda, idxOrdenados] = sort(datos.Var16(idxPerfil)); 
            arrayPerfil(:, 1) = fechas(idxPerfil(idxOrdenados)); % Fecha de medida
            arrayPerfil(:, 2) = datos.Var14(idxPerfil(idxOrdenados)); % Latitud
            arrayPerfil(:, 3) = datos.Var15(idxPerfil(idxOrdenados)); % Longitud
            arrayPerfil(:, 4) = datos.Var16(idxPerfil(idxOrdenados)); % Altitud
            % arrayPerfil(:, 5) = datos.Var22(idxPerfil(idxOrdenados)); % Presion
            arrayPerfil(:, 5) = datos.Var25(idxPerfil(idxOrdenados)); % Dir Viento
            arrayPerfil(:, 6) = datos.Var26(idxPerfil(idxOrdenados)); % Vel Viento
            % arrayPerfil(:, 8) = datos.Var29(idxPerfil(idxOrdenados)); % Turbulence 
            arrayPerfil(:, 7) = datos.Var31(idxPerfil(idxOrdenados)); % Temperatura
            % arrayPerfil(:, 10) = datos.Var32(idxPerfil(idxOrdenados)); % Dew point Temperatura 
            % arrayPerfil(:, 11) = datos.Var33(idxPerfil(idxOrdenados)); % RH% 
            % plot(arrayPerfil(:, 9), arrayPerfil(:, 4));
            % Graba los perfiles en ficheros csv, un fichero por ascenso/descenso
            % En formato Comma Separated Values CSV
%             nombreFicPerfil = ['Perfil_' datestr(arrayPerfil(1, 1), 'YYYYmmdd_HHMM') '.csv'];
%             dirPerfil = '\\cendat2\lidar\CEDA archive AMDAR files\Perfiles';
%             csvwrite(fullfile(dirPerfil, nombreFicPerfil), arrayPerfil);
            % En formato netCDF
            nombreFicPerfil = ['Perfil_' datestr(arrayPerfil(1, 1), 'YYYYmmdd_HHMM') '.nc'];
            dirPerfil = '\\cendat2\lidar\CEDA archive AMDAR files\Perfiles';
            saveAMDARprofile_NC(fullfile(dirPerfil, nombreFicPerfil), arrayPerfil);
            
            disp(['Fichero grabado: ' nombreFicPerfil])
            resumen(idxResumen).Dia = datestr(fechas(idxPerfil(1)), 'dd/mm/yyyy');
            resumen(idxResumen).Hora = datestr(fechas(idxPerfil(1)), 'HH:MM');
            resumen(idxResumen).numAltitudes = length(idxPerfil);
            resumen(idxResumen).numPerfiles = dimPerfiles(2);
            idxResumen = idxResumen + 1;
        end %if
    end %for 
end % for
save(fullfile('\\cendat2\lidar\CEDA archive AMDAR files\', 'Resumen.mat'), 'resumen');






