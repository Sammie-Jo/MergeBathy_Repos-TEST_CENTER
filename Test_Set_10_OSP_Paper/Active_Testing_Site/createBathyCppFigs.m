%Create Figs
function createBathyCppFigs 


% hold on;
% axis image
% [cmin, cmax]=caxis;
% NCEX
%  caxis([-700,0]);
%  caxis([-50,50]);

%  hold on;
%  [cmin, cmax]=caxis;
%  caxis([cmin/10,cmax/10]);

% DBDBV
%  caxis([-3000,0]);
%  caxis([-50,50]);



%%
% data.utmzone = {'999'};
transpose = 0;
HEADER = 1;
MATLAB_FORMAT = 0;
gxs = [50 10 10 10]; %grid size x
gys = [50 10 10 10]; %grid size y
lxs = [50 10 20 20]; %smoothing x
lys = [50 10 20 100]; %smoothing y
LL = 0;
filtername = 'hann'; %'boxcar' 'quadloess' 'loess';
errplots = 1; 
smoothplots = 0; 
plotpts = 1; 
scale = 1;	% contours in meters
rect_ll = 0;
local = 0;
useutm = 1;
if LL
	useutm = 0
end
saveplots = 1;
calcgrid = 1;
nethresh = 0.75;
allownegativedepth = 0; 
modelflag = 1; 
itersmooth = 0; %ALWAYS itersmooth = 0! because CPP doesnt do this
% Directory for Test Set to run
% TestSetRoot='Test_Set_01_runValidationData_Kevins/Active_Testing_Site/';

% Directory for output files from MergeBathy to plot
outputDir = 'output_files/';
bitFlag   = 'x86/';
% bitFlag = 'x64/';
configFlag   = 'Debug';
% configFlag = 'Release';

%%
loc = [[outputDir bitFlag] configFlag];

figDir = 'figs';
[s, m1, m2] = mkdir(['../Active_Testing_site/' loc], figDir);
loc = [loc '/'];
figDir = [figDir '/'];

fList= char('T10C01_CPP_DUCK_50x50g_50x50s.txt',...
	'T10C02_CPP_DUCK_10x10g_10x10s.txt',...
	'T10C03_CPP_DUCK_10x10g_20x20s.txt',...
	'T10C04_CPP_DUCK_10x10g_20x100s.txt');

 bathyTitles = char('Duck 50x50m Grid with 50x50m Hann smoothing Bathymetry',...
	'Duck 10x10m Grid with 10x10m Hann smoothing Bathymetry',...
	'Duck 10x10m Grid with 20x20m Hann smoothing Bathymetry',...
	'Duck 10x10m Grid with 20x100m Hann smoothing Bathymetry');
 
 uncertTitles = char('Duck 50x50m Grid with 50x50m Hann smoothing Uncertainty',...
	'Duck 10x10m Grid with 10x10m Hann smoothing Uncertainty',...
	'Duck 10x10m Grid with 20x20m Hann smoothing Uncertainty',...
	'Duck 10x10m Grid with 20x100m Hann smoothing Uncertainty');
 
  bathyFigs = char('T10C01_Duck_50x50g_50x50s_Bathy',...
	'T10C02_Duck_10x10g_10x10s_Bathy',... 
	'T10C03_Duck_10x10g_20x20s_Bathy',...
	'T10C04_Duck_10x10g_20x100s_Bathy');
 
 uncertFigs = char('T10C01_Duck_50x50g_50x50s_Uncert',...
	'T10C02_Duck_10x10g_10x10s_Uncert',... 
	'T10C03_Duck_10x10g_20x20s_Uncert',...
	'T10C04_Duck_10x10g_20x100s_Uncert');
 figs = char('T10C01_Duck_50x50g_50x50s',...
	'T10C02_Duck_10x10g_10x10s',... 
	'T10C03_Duck_10x10g_20x20s',...
	'T10C04_Duck_10x10g_20x100s');
 [r,c] = size(fList);
 for cnt=1:r
    cFile = fList(cnt,:);
	fileID = fopen([loc cFile],'r');
	if HEADER
		fgetl(fileID);
	end
	if ~MATLAB_FORMAT
		sizeA = [6 Inf];
		[A count] = fscanf(fileID,'%f %f %f %f %f %f\n',sizeA);
	else
		sizeA = [11 Inf];
		[A count] = fscanf(fileID,'%f %f %f %f %f %f %f %f %f %f %f\n',sizeA);	
	% 	[A count] = fscanf(fileID,'%f %f %f %*f %*f %*f %f %f %f %*f %*f\n',sizeA);	
	end
	fclose(fileID);

	dx = gxs(cnt); %grid size x
	dy = gys(cnt); %grid size y
	lx = lxs(cnt); %smoothing x
	ly = lys(cnt); %smoothing y
	lx0 = lx;
	ly0 = ly;
	%
	xt = linspace(min(A(1,:)),max(A(1,:)),dx);
	yt = linspace(min(A(2,:)),max(A(2,:)),dy);
	[x y] = meshgrid(xt,yt);
	Zi = griddata(A(1,:),A(2,:),A(3,:),x,y);
	Ei = griddata(A(1,:),A(2,:),A(4,:),x,y);
	NEi = griddata(A(1,:),A(2,:),A(5,:),x,y);
	REi = griddata(A(1,:),A(2,:),A(6,:),x,y);
	if MATLAB_FORMAT
		K_Z = griddata(A(1,:),A(2,:),A(10,:),x,y);
		K_VAR = griddata(A(1,:),A(2,:),A(11,:),x,y);
	end
	gridlat=y; gridlon=x; 

	data(1).x = x(:);
	data(1).y = y(:);
	data(1).lon = x(:);
	data(1).lat = y(:);
	
	%Comment this out to use in Lat Lon
	%Comment in to convert to UTM and do the transposes and
	%orientations
	ref_lon = -75.749690; ref_lat = 36.177602; rotation_angle = 18.20;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
	if ~LL
		[data.x,data.y,data.utmzone] = latlon2csas(A(2,:),A(1,:),ref_lat,ref_lon,rotation_angle);
		xt = linspace(min(data.x),max(data.x),dx);
		yt = linspace(min(data.y),max(data.y),dy);
		[x y] = meshgrid(xt,yt);
		Zi = griddata(data.x,data.y,A(3,:),x,y);
		Ei = griddata(data.x,data.y,A(4,:),x,y);
		NEi = griddata(data.x,data.y,A(5,:),x,y);
		REi = griddata(data.x,data.y,A(6,:),x,y);
		if MATLAB_FORMAT
			K_Z = griddata(data.x,data.y,A(10,:),x,y);
			K_VAR = griddata(data.x,data.y,A(11,:),x,y);
		end
		gridlat=y; gridlon=x; 
	end
	lons = cat(1,data.lon);
	if(((min(lons) < 0 & max(lons) > 0) & (0-min(lons) > 180+min(lons))))
		if(clon < 0)
			clon = clon + 360;
		end
		for i = 1:length(data)
			disp('Datasets straddle anti meridian.  Change lons to 0-360.');
			id = find(data(i).lon < 0);
			data(i).lon(id) = data(i).lon(id) + 360;
			[data(i).x,data(i).y,data(i).utmzone] = latlon2csas(data(i).lat,data(i).lon,clat,clon,rot_angle);
		end
	end
	if (useutm)
		% Set scene center lat/lon for use with UTM gridding
		% Not necessary if local coordinate system specified)
		clat = mean(cat(1,data.lat));
		clon = mean(cat(1,data.lon));

		% Make sure all datasets are referenced to the same UTM zone
		for i=1:length(data)
			zone(i) = data(i).utmzone(1); %SJZ
		end
		if (any(~strcmp(zone(1),zone)))%find mismatching
		%   disp('UTM zone not consistent between datasets.  Please re-run mergeBathy with a non-zero reference position/rotation angle.');

			%new code:
			%Changed 10/24/14 to reproject each "errant" dataset
			% into the "majority" zone.  Force the zones.  SJZ
			zonestring = '';
			refellip = 23;   % this number corresponds to WGS-84
			for i=1:length(data)
				zonestring = strcat(zonestring,data(i).utmzone(1));
			end
			zonestring = char(zonestring);
			for i=1:length(data)
				agree(i) = length(findstr(zonestring,char(data(i).utmzone(1))));
			end
			agreeindex = find(agree == max(agree));
			agreeindex = agreeindex(1);
			zone = data(agreeindex).utmzone(1);
			for i=1:length(data)
				if (~strcmp(zone,data(i).utmzone(1)))
					disp('reprojecting UTM coordinates into majority zone');
					data(i).utmzone = {zone};
					[data(i).y, data(i).x, data(i).utmzone] = ll2UTM(data(i).lat, data(i).lon, refellip, zone);
				end
			end
		else
		zone = zone(1);	
		end
	else
		zone = '999';
	end
	
    x0 = floor(min(cat(1,data.x)));
    x1 = ceil(max(cat(1,data.x)));
    y0 = floor(min(cat(1,data.y)));
    y1 = ceil(max(cat(1,data.y)));
	lat0 = min(cat(1,data.lat));
    lat1 = max(cat(1,data.lat));
    lon0 = min(cat(1,data.lon));
    lon1 = max(cat(1,data.lon));
	if (~rect_ll)
        %   Determine orientation (for mappish display later)
        if (~local)
            if (rot_angle <= 45 | rot_angle > 315)
                flip = 0;
                transpose = 0;
            elseif (rot_angle > 45 & rot_angle <= 135)
                flip = 1;
                transpose = 1;
            elseif (rot_angle > 135 & rot_angle <= 225)
                flip = 1;
                transpose = 0;
            elseif (rot_angle > 225 & rot_angle <= 315)
                flip = 0;
                transpose = 1;
            end
        end
    else
%         latscale = cos(pi*mean(cat(1,data.lat))/180.0);
%         llgdx = dx/(deg2km(latscale)*1000); % (111120.0*latscale);
%         llgdy = dy/(deg2km(1)*1000); % 111120.0;
%  		xt = lon0-llgdx:llgdx:lon1+llgdx; %wea
%         yt = lat0-llgdy:llgdy:lat1+llgdy;
%         [x,y] = meshgrid(xt,yt);
        [i1,i2] = size(x);
        x = reshape(x,i1*i2,1);
        y = reshape(y,i1*i2,1);
%         [mx,my] = latlon2csas(y,x,clat,clon,rot_angle);
		mx= x; my=y;
        kbound = find(mx >= x0 & mx <= x1 & my >= y0 & my <= y1);
        x = mx(kbound);
        y = my(kbound);
    end
	
	
	
	
	
	
	%Generate Bathymetry Figures===========================================
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	nescale = median(NEi(~isnan(NEi))) + 0.1;
	if (nescale > 0.95)
		nescale = 0.95;
	end
	nescale = max(nescale,nethresh);  % removes edge extrapolation effects

	if (min(min(NEi)) > nescale)
		nescale = min(NEi(:)) + 0.1;
	end

	% Changed 4/10/14 for NAVO Test
	if (allownegativedepth) % not sure what Marc has going on here
		ib = find(NEi > nescale); % really poor samples
% 		ib0 = find(NEi > nescale); 
		ibK = find(NEi > nescale); 
	else
		ib = find(NEi > nescale | Zi < 0.1);
% 		ib0 = find(NEi > nescale | Zi0 < 0.1);
		if MATLAB_FORMAT
			ibK = find(NEi > nescale | K_Z < 0.1);%sam
		end
	end

	if modelflag % do not nan points below
		ib = []; % nothing is bad
% 		ib0 = []; 
		if MATLAB_FORMAT
			ibK = []; 
		end
	else
		disp(sprintf('Points with normalized errors greater than %f removed.',nescale));
	end
	% Comment out following if want to keep ALL interpolated points (including where you shouldn't)
	Zi(ib) = Zi(ib)*nan; %WEA
	Ei(ib) = Ei(ib)*nan; %SJZ
	NEi(ib) = NEi(ib)*nan; %SJZ
	REi(ib) = REi(ib)*nan; %SJZ
% 	Zi0(ib0) = Zi0(ib0)*nan;%SJZ
% 	STD_Zi(ib0) = STD_Zi(ib0)*nan;%SJZ
	if MATLAB_FORMAT
		K_Z(ibK) = K_Z(ibK)*nan;%SJZ
		K_VAR(ibK) = K_VAR(ibK)*nan;%SJZ
	end
	% disp('nescale NOT being applied as filter');

	if (~itersmooth)
		if (length(lx) == 1 & length(ly) == 1)    % constant smoothing scales
			lx = ones(size(Zi))*lx0;
			ly = ones(size(Zi))*ly0;
		else                                    % dynamic smoothing scales
			lx = griddata(cat(1,data.x),cat(1,data.y),lx,x,y);
			ly = griddata(cat(1,data.x),cat(1,data.y),ly,x,y);
		end
	end
	ib = find(isnan(Zi));
	lx(ib) = ones(size(ib))*nan;
	ly(ib) = ones(size(ib))*nan;

	if (rect_ll)	%%% reformat results into non-cropped array for display purposes
		frame = ones(length(xt)*length(yt),1)*nan; %ngp comment out nan
		frame(kbound) = Zi;
		Zi = frame;
		frame(kbound) = Ei;
		Ei = frame;
		frame(kbound) = NEi;
		NEi = frame;
		frame(kbound) = REi;
		REi = frame;
% 		frame(kbound) = Zi0;
% 		Zi0 = frame;
% 		frame(kbound) = STD_Zi;
% 		STD_Zi = frame;
		if MATLAB_FORMAT
			frame(kbound) = K_Z;
			K_Z = frame;
			frame(kbound) = K_VAR;
			K_VAR = frame;
		end
		frame(kbound) = lx;
		lx = frame;
		frame(kbound) = ly;
		ly = frame;
		x = mx;
		y = my;
	end

	if (calcgrid)
		if (useutm)
			[gridlat,gridlon] = csas2latlon(x,y,clat,clon,rot_angle,zone);
		else
			[gridlat,gridlon] = csas2latlon(x,y,clat,clon,rot_angle);
		end
		Zi = reshape(Zi,length(yt),length(xt));
		Ei = reshape(Ei,length(yt),length(xt));
		NEi = reshape(NEi,length(yt),length(xt));
		REi = reshape(REi,length(yt),length(xt));
% 		Zi0 = reshape(Zi0,length(yt),length(xt));
% 		STD_Zi = reshape(STD_Zi,length(yt),length(xt));
		if MATLAB_FORMAT
			K_Z = reshape(K_Z,length(yt),length(xt));
			K_VAR = reshape(K_VAR,length(yt),length(xt));
		end
		lx = reshape(lx,length(yt),length(xt));
		ly = reshape(ly,length(yt),length(xt));
		gridlat = reshape(gridlat,length(yt),length(xt));
		gridlon = reshape(gridlon,length(yt),length(xt));
% 		outx = reshape(x,length(yt),length(xt));
% 		outy = reshape(y,length(yt),length(xt));
	end

	if (~local)
		if (transpose)
			Zi = Zi';
			Ei = Ei';
			NEi = NEi';
			REi = REi';
% 			Zi0 = Zi0';
% 			STD_Zi = STD_Zi';
			if MATLAB_FORMAT
				K_Z = K_Z';
				K_VAR = K_VAR';
			end
			lx = lx';
			ly = ly';
			%Added 4/10/14 for NAVO Test
% 			outx = outx';
% 			outy = outy';
			if (calcgrid)
				gridlat = gridlat';
				gridlon = gridlon';
			end
			temp = yt;
			yt = xt;
			xt = temp;
		end
	end
	
	
	
	
	
	% Determine which graphics to display

	root = [[loc figDir] figs(cnt,:)];
	if (errplots)
		toshow = 1:4;
	%     toshow = 1:8;
		if MATLAB_FORMAT
			toshow = [toshow 7 8];
		end
	else
		toshow = 1;
	end
	if (smoothplots)
	%     toshow = [toshow, 5, 6];
		toshow = [toshow, 9, 10];
	end
	if(calcgrid)
		minZ = 0;
		minlat = min(min(floor(gridlat*30)/30));
		maxlat = max(max(ceil(gridlat*30)/30));
		minlon = min(min(floor(gridlon*30)/30));
		maxlon = max(max(ceil(gridlon*30)/30));

		for j=1:length(toshow)
			ZiTemp = Zi;
			maxZ = ceil(max(max(Zi)));
			% select the error field to show
			figure
			switch toshow(j)
				case 1
					E = Zi(:,:);
					if (scale == 1)
						titstr = 'Bathymetric surface [m]';
					else
						titstr = 'Bathymetric surface [ft]';
					end
					colormap(flipud(jet)); % blue water, warm land
					graphextension = '';
				case 2
					E = NEi(:,:);
					titstr = 'normalized error estimate';
					colormap((jet)); % hot errors
					graphextension = '_normrms';
				case 3
					E = REi(:,:);
					if (scale == 1)
						titstr = 'residual error estimate (m)';
					else
						titstr = 'residual error estimate (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_rmsres';%'_rmserr';%sam
				case 4
					E = Ei(:,:);
					if (scale == 1)
						titstr = 'rms error estimate (Ei) (m)';
					else
						titstr = 'rms error estimate (Ei) (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_rmserr';%'_rmsres'; %sam 
				case 5
					% updated ZiTemp to reflect PropUncert depths in contours
					ZiTemp = Zi0;
					maxZ = ceil(max(max(Zi0)));
					E = Zi0(:,:);
					if (scale == 1)
						titstr = 'PropUncert Bathymetric surface [m]';
					else
						titstr = 'PropUncert Bathymetric surface [ft]';
					end
					colormap(flipud(jet)); % blue water, warm land
					graphextension = '_zi0';
				case 6
					% updated ZiTemp to reflect PropUncert depths in contours
					ZiTemp = Zi0;
					maxZ = ceil(max(max(Zi0)));
					E = STD_Zi(:,:);
					if (scale == 1)
						titstr = 'PropUncert error estimate (m)';
					else
						titstr = 'PropUncert error estimate (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_stdzi';
				case 7
					% updated ZiTemp to reflect Kalman depths in contours
					ZiTemp = K_Z;
					maxZ = ceil(max(max(K_Z)));
					E = K_Z(:,:);
					if (scale == 1)
						titstr = 'Kalman Bathymetric surface [m]';
					else
						titstr = 'Kalman Bathymetric surface [ft]';
					end
					colormap(flipud(jet)); % blue water, warm land
					graphextension = '_kz';
				case 8
					% updated ZiTemp to reflect Kalman depths in contours
					ZiTemp = K_Z; 
					maxZ = ceil(max(max(K_Z)));
					E = K_VAR(:,:);
					if (scale == 1)
						titstr = 'Kalman error estimate (m)';
					else
						titstr = 'Kalman error estimate (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_kvar';
				case 9
					E = lx(:,:);
					titstr = 'X smoothing scales (m)';
					colormap((jet)); % hot errors
					graphextension = '_lx';
				case 10
					E = ly(:,:);
					titstr = 'Y smoothing scales (m)';
					colormap((jet)); % hot errors
					graphextension = '_ly';
			end

			pcolor(xt,yt,E); shading('interp'); %was shading flat - but that displaces array!!

			rightrange = round(caxis*10)/10; % workaround to fix bug in matlab7 contour
			%Added 10/16/15 to fix non-increasing values SJZ
			if(rightrange(1)==rightrange(2))
				rightrange = caxis;
			end
			h = colorbar;
			hold on;

			dZset = [1 2 5 10 20 25 50 100];
			dZind = 1;
			numCont = length(minZ:dZset(dZind):maxZ);
			while (numCont > 20 && dZind < 8)
				dZind = dZind + 1;
				numCont = length(minZ:dZset(dZind):maxZ);
			end
			dZ = dZset(dZind);

			[c h] = contour(xt,yt,ZiTemp(:,:),minZ:dZ:maxZ, '-'); % every meter
			hand = h;
			for k=1:length(h)
				set(h(k),'LineStyle','-', 'color', 'b');
			end
			clabel(c,h,minZ:2*dZ:maxZ,'FontSize',12);
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			dlat = ((maxlat-minlat)*60)/2;
			if dlat > 20
				dlat = 20;
			elseif dlat > 2
				dlat = 2;
			end

			[c2,h2] = contour(xt,yt,gridlat,minlat:dlat/60:maxlat, 'r-');
			if (length(h2) >= 1)
				clabel(c2,h2,minlat:dlat/60:maxlat,'Color', 'r');
			end

			dlon = ((maxlon-minlon)*60)/2;

			[c3,h3] = contour(xt,yt,gridlon,minlon:dlon/60:maxlon, 'r-');
			caxis(rightrange); % reset to original
			if (length(h3) >= 1)
				clabel(c3,h3,minlon:dlon/60:maxlon,'Color', 'r');
			end

			axis([min(xt) max(xt) min(yt) max(yt)]); % do this now before plotting points
			axis('image');
			axis xy;

			if plotpts
				if ~rect_ll
					if (local | ~transpose)
						plot(cat(1,data.x),cat(1,data.y), 'm.', 'markersize',1);
					else
						plot(cat(1,data.y),cat(1,data.x), 'm.', 'markersize',1);
					end
				else
					plot(cat(1,data.lon),cat(1,data.lat), 'm.', 'markersize',1);
				end
			end

			title([titstr],'FontSize',16);
			set(gcf,'Name',titstr);
			if (rect_ll)
				xlabel('Longitude (deg)');
				ylabel('Latitude (deg)');
			else
				if (useutm)
					xlabel(sprintf('X (m) UTM [Zone %s]',char(zone)));
					ylabel(sprintf('Y (m) UTM [Zone %s]',char(zone)));
					ah = gca;
					set(ah,'FontSize',8);
					ticks = get(ah,'XTick');
					for k=1:length(ticks);
						newxtick(k,:) = {sprintf('%0.0f',ticks(k))};
					end
					set(ah,'XTickLabel',newxtick);
					set(ah,'XTick',ticks);
					ticks = get(ah,'YTick');
					for k=1:length(ticks);
						newytick(k,:) = {sprintf('%0.0f',ticks(k))};
					end
					set(ah,'YTickLabel',newytick);
					set(ah,'YTick',ticks);
				else
					if (local | ~transpose)
						xlabel('x (m)');
						ylabel('y (m)');
					else
						ylabel('x (m)');
						xlabel('y (m)');
					end
				end
			end
			hold off;

			if (~local)
				if (flip & ~transpose)
					set(gca,'YDir','reverse');
					set(gca,'XDir','reverse');
				elseif (transpose & ~flip)
					set(gca,'XDir','reverse');
				elseif (flip & transpose)
					set(gca,'YDir','reverse');
				end
			end
			drawnow;

			if (saveplots)
			graphoutname = strcat(root,'_bathy_',filtername,graphextension,'.jpg');
			saveas(gcf, graphoutname, 'jpg'); % used to be print(graphoutname,'-djpeg');
			graphoutname = strcat(root,'_bathy_',filtername,graphextension,'.fig');
			hgsave(graphoutname);
			end
		end
	end	% whether or not to display results

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	figure; surf(xs,ys,vs); colorbar; view(2); shading interp;
    %set(gca, 'Clim', [-11000 -6000]);
%   SaveFig( bathyTitles(cnt,:), [[loc figDir] bathyFigs(cnt,:)], 'Bathymetry');
    LabelFig(bathyTitles(cnt,:),'Bathymetry');
    SaveFig( [[loc figDir] bathyFigs(cnt,:)] );
    FormatFig(cnt,1,[[loc figDir] bathyFigs(cnt,:)]);
    
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
    %Generate Uncertainty Figures==========================================
    B = geoDataArray([loc cFile], 4);
    figure; surf(B, 1000, 1000, 'regrid'); 
%    set(gca, 'Clim', [0 20]);
%    figure; plot(B, 'ColorZ')
    
%     c = bboxcut(b, 13.1, 12.9, 146, 146.2)  
% %    figure; plot(c)
% %    figure; plot(c, 'colorz')
% 
%     figure; surf(c, 1000, 1000, 'regrid')
%     figure; surf(geolimit(c, 10) , 1000, 1000, 'regrid')
%  
%     SaveFig( uncertTitles(cnt,:), [[loc figDir] uncertFigs(cnt,:)], 'Uncertainty');
    LabelFig(uncertTitles(cnt,:),'Uncertainty');
    SaveFig( [[loc figDir] uncertFigs(cnt,:)] );
    FormatFig(cnt,2,[[loc figDir] uncertFigs(cnt,:)]);
    
    if(cnt==3) 
        D1=B;
    elseif(cnt==4)
        D3=B;
    elseif(cnt==9)
        D2=B;
    elseif(cnt==10)
        D4=B;
    end
 end
 
  % Print DBDBV uncertainty differences when kriging
  D = D2 - D1; %DBDBV_Uncertainty - DBDBV_Uncertainty_Krig
  figure; surf(D, 1000, 1000, 'regrid'); 
%   SaveFig( 'DBDBV Kriging Uncertainty Differences', [[loc figDir] 'DBDBV_Kriging_Uncert_Diffs'], 'Uncertainty');
  LabelFig('DBDBV Kriging Uncertainty Differences','Uncertainty');
  SaveFig( [[loc figDir] 'DBDBV_Kriging_Uncert_Diffs'] );
  FormatFig(cnt+1,2,[[loc figDir] 'DBDBV_Kriging_Uncert_Diffs']);

  
  D = D4 - D3; %DBDBV_Uncertainty_NoOverlap - DBDBV_Uncertainty_Krig_NoOverlap
  figure; surf(D, 1000, 1000, 'regrid'); 
  LabelFig('DBDBV Kriging Uncertainty No Overlap Differences','Uncertainty');
  SaveFig( [[loc figDir] 'DBDBV_Kriging_Uncert_NoOverlap_Diffs'] );
  FormatFig(cnt+1,2,[[loc figDir] 'DBDBV_Kriging_Uncert_NoOverlap_Diffs']);

  
end

 function LabelFig(figTitle, yLabel)
 
  % Figure Formating
    xlabel('Longitude', 'FontSize', 14)
    ylabel('Latitude', 'FontSize', 14)
    set(gca, 'FontSize', 14)
    title(figTitle, 'FontSize', 14)
    h = colorbar;
    set(h, 'FontSize', 14)
    set(get(h, 'YLabel'), 'String', strcat(yLabel,' (m)'), 'FontSize', 14)
 end
 
 function SaveFig(figFile)

    cFigFile = figFile;
    cnt2=1;
    while (exist(strcat(cFigFile,'.jpg'),'file')~=0)
        cnt2= cnt2 + 1;
        cFigFile= strcat(figFile,'_', int2str(cnt2));
    end
    print('-djpeg', '-r300', strtrim(cFigFile));
    hgsave(strtrim(cFigFile));
 end
 
 function FormatFig(cnt,fflag,figFile)
    if((cnt==1 || cnt==2) || (cnt==7 || cnt==8)) %NCEX
        hold on;
        axis image;
        if fflag==1
            caxis([-700,0]);
        else 
            caxis([-50,50]);
        end
        hold off;
        SaveFig( strcat(figFile, '_Formatted'));
    elseif((cnt==3 || cnt==4) || (cnt==9 || cnt==10) || cnt==13)%DBDBV
        hold on;
        axis image;
        if fflag==1
            caxis([-3000,0]);
        else
            caxis([-50,50]);
        end
        hold off;
        SaveFig( strcat(figFile, '_Formatted'));
    end
 end
