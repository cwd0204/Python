create temporary table box distkey(shipper_id) as 
(
    -- Box Details
       select shipper_id, 
                max(actual_box_barcode) as actual_box_barcode, 
                max(recommended_box_barcode) as             recommended_box_barcode
       from BOOKER.D_COMPLETED_CUST_SHIP_PKGS
       where legal_entity_id = 131
       and marketplace_id = 44571
       and ship_day >= to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180   
       group by shipper_id
);

create temporary table PINDISTANCE  as 
(
    SELECT    
    CAST(ROUND(PINCODE_SRC,0) AS VARCHAR) AS PINCODE_SRC,    
    CAST(ROUND(PINCODE_DST,0) AS VARCHAR) AS PINCODE_DST,    
    MAX(COALESCE(DISTANCE_IN_KM,0)) AS distance_in_km
    FROM scap.D_PINCODE_DISTANCE_MX_IN       
    GROUP BY     
    CAST(ROUND(PINCODE_SRC,0) AS VARCHAR),    
    CAST(ROUND(PINCODE_DST,0) AS VARCHAR) 
);

/*===============================================================================================*/
create temporary table WHIDPIN  as 

(
SELECT warehouse_id
    ,pincode
    ,alternate_pincode
    ,pincode_diff
FROM (
SELECT dws.warehouse_id
,dws.pincode
,dist.pincode_src AS alternate_pincode
,abs(dws.pincode - dist.pincode_src) AS pincode_diff
,RANK() OVER (PARTITION BY dws.warehouse_id ORDER BY abs(dws.pincode - dist.pincode_src)) AS Alt_Zip_Rank
,RANK() OVER (PARTITION BY dws.warehouse_id , abs(dws.pincode - dist.pincode_src) ORDER BY dist.pincode_src) AS Zip_Rank

FROM scap.D_WAREHOUSES_SUMMARY_HOOT dws
    
INNER JOIN (
SELECT pincode_src
FROM scap.D_PINCODE_DISTANCE_MX_IN
GROUP BY pincode_src ) dist
ON 1 = 1
) Combined_Table
WHERE Alt_Zip_Rank = 1
AND Zip_Rank = 1
);

/*===============================================================================================*/
 create temporary table final
 as (
select
ship_year,
SHIP_MONTH,
ship_Week,
NVL(actual_box_barcode,recommended_box_barcode) as box,
DISTRICT_NAME,
warehouse_id,
damage_type,
shipper_id,
sum(concession_value) as concession_value,
sum(TOTAL_UNITS_CONCEDED) as TOTAL_UNITS_CONCEDED,
CASE WHEN pd.distance_in_km>=0 AND pd.distance_in_km<=60 THEN 'Local'
ELSE 'Regional' END  AS DISTANCE_ZONE,DSTPOST
    
from
(select
ord.REPORTING_YEAR as ship_year, 
((ord.calendar_year*100)+ (ord.CALENDAR_MONTH_OF_YEAR)) AS SHIP_MONTH,
ord.reporting_week_of_year ship_Week, 
duc.CONCEDED_ORDER_ID, 
duc.CONCEDED_ORDER_ITEM_ID,
duc.CONCEDED_SHIPMENT_ID,
duc.CONCEDED_SHIPMENT_ITEM_ID,
duc.return_item_id,
duc.unit_id, 
net.NET_CONCESSION_VALUE,
(duc.concession_value + DUC.CONCESSION_VALUE_TAX) as concession_value,
duc.warehouse_id, 
DUC.TOTAL_UNITS_CONCEDED,  
box.actual_box_barcode,
box.recommended_box_barcode,
PIN.DISTRICT_NAME, 
DOSP.warehouse_id as whid,
wp.alternate_pincode as Srcpin,
DOSP.shipping_address_postal_code as DSTPOST,
DOSP.from_postal as SRCPOST, 
SIP.shipper_id,
min(case when duc.concession_reason in ('Damaged due to inappropriate packaging','Damaged during shipping',
    'damaged_item_by_fc','damaged_item_by_shipper','damaged_item_undetermined_cause','damaged_pkg_item_missing', 'packing_error') then 'Customer Claimed Damage' 
    when carrier_damage.customer_shipment_item_id is not null then 'Undeliverable Carrier Damages'  
 else 'Others'
 end) as damage_type
    
  FROM
CSBOOKER.D_UNIFIED_CONCESSIONS   DUC

        
    left join csinsight.D_UNIFIED_CONCESSIONS_net net
        on net.REGION_ID = 4 
        AND net.MARKETPLACE_ID = 44571
        AND DUC.CONCESSION_ID = net.CONCESSION_ID 
        AND DUC.CONCEDED_ORDER_ID = net.CONCEDED_ORDER_ID 
        AND DUC.CONCEDED_SHIPMENT_ID = net.CONCEDED_SHIPMENT_ID 
        AND DUC.CONCEDED_ORDER_ITEM_ID = net.CONCEDED_ORDER_ITEM_ID 
        AND DUC.CONCEDED_SHIPMENT_ITEM_ID = net.CONCEDED_SHIPMENT_ITEM_ID 
        AND DUC.ORIG_CONCESSION_ID=net.ORIG_CONCESSION_ID
        AND DUC.concession_creation_day = net.concession_creation_day
        and duc.return_item_id = net.return_item_id
        and duc.unit_id = net.unit_id
        and NVL(net.SHIP_DAY, net.CONCESSION_CREATION_DAY) >= to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180        
 
  Left JOIN
    (
        SELECT
            customer_shipment_item_id
        FROM
            booker.d_customer_return_items
        WHERE
            return_day >= to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180
            AND item_reason_code IN (150,151,152,153,154,155,156)
        and CONDITION_CODE <> 0 -- verify codes with sandeep
            AND marketplace_id = 44571
        GROUP BY
            1
    ) AS carrier_damage
    ON DUC.CONCEDED_SHIPMENT_ITEM_ID = carrier_damage.customer_shipment_item_id
        
    
    Left JOIN 
        booker.D_CUST_SHIPMENT_ITEM_PKGS SIP 
        ON SIP.SHIPMENT_ID = duc.CONCEDED_SHIPMENT_ID 
        AND SIP.REGION_ID=4 
        AND SIP.ORDER_ID = duc.CONCEDED_ORDER_ID 
        AND SIP.CUSTOMER_SHIPMENT_ITEM_ID=duc.CONCEDED_SHIPMENT_ITEM_ID 
        AND SIP.ASIN = duc.ASIN
        AND SIP.SHIP_DAY >= to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180
        AND SIP.OTM_OBCUST_PKG_REC_ID <> '-1'

 
    LEFT JOIN BOOKER.D_OUTBOUND_SHIPMENT_PACKAGES AS DOSP 
        ON DOSP.FULFILLMENT_SHIPMENT_ID = SIP.FULFILLMENT_SHIPMENT_ID
        AND DOSP.REGION_ID = 4
        AND DOSP.MARKETPLACE_ID = 44571
        AND DOSP.SHIP_DAY >= to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180
        
    left join booker.o_reporting_days ord 
        on ord.calendar_day=NVL(DUC.ship_day,duc.concession_creation_day)
 
 
    Left JOIN BOX    
        ON BOX.SHIPPER_ID = SIP.shipper_id      
 
    left join booker.d_addresses da 
            on da.address_id =  sip.SHIPPING_ADDRESS
    
    LEFT JOIN
          (select 
            postal_code,max(state_name) as state_name, max(district_name) as district_name
            from STA_IN_CPU_INT_DDL.POSTAL_CODE_MAPPING 
            group by postal_code) pin
            ON da.postal_code=pin.postal_code
 
     LEFT JOIN WHIDPIN wp
        ON wp.warehouse_id = SIP.warehouse_id
       
    WHERE duc.concession_creation_Day >= to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180
        and NVL(duc.SHIP_DAY,duc.concession_creation_Day) between to_date('{RUN_DATE_YYYY/MM/DD}','YYYY/MM/DD') -180 and TO_DATE('{RUN_DATE_YYYYMMDD}','YYYYMMDD') 
        AND DUC.REGION_ID = 4 
        AND DUC.MARKETPLACE_ID = 44571 
        AND DUC.IS_ACTIVE = 'Y' 
        AND DUC.CONCESSION_STATUS NOT IN (2,3) /*2=Canceled status, 3=Unused Return Merchandise Authorization (RMA)*/
        AND (DUC.CONCESSION_REASON <> 'prerelease_shipment_price_guarantee' OR DUC.CONCESSION_REASON IS NULL) /*Excludes prerelease shipment price guarantees*/
        AND (
                DUC.CONCESSION_TYPE_CODE <> 'free_repl' 
            OR (DUC.CONCESSION_TYPE_CODE = 'free_repl' and DUC.CONCESSION_VALUE <> 0) ) /*Excludes charge replacements*/
        AND DUC.CONCESSION_TYPE_CODE NOT IN('tax_refund','dig_refund','alr_gdwill','kus_refund','wrnty_repl','dig_refund_other')
              /* Excludes sales tax refunds and digital concession types */  
        AND NVL(DUC.GL_PRODUCT_GROUP,-1) NOT IN (356,438,493,400,136,129,449,437,448,447
                                                                     ,450,465,425,451,494,402,4180,426,424,410
                                                                     ,111,405,412,411,414,349,485,487,489,545
                                                                     ,546,547,548,549,550,551,552,553,554,555
                                                                     ,556,557,558,559,560,561,561,562,563,564
                                                                     ,5180,596,639,634,633,628,626,624,620,640                                                                                                                             ,613,611,609,297,298,318,327,334,340,350
                                                                     ,351,366,367,406,407,408,409,438,500,610,644
                                                )
        AND NOT 
        (
                DUC.CONCEDED_ORDER_ID = '-1' 
            AND DUC.CONCESSION_REASON IN ('TRADEEXCEP','tradein_received_not_processed','tradein_returned_damaged',
                                          'tradein_returned_not_received', 'tradein_shipped_30d_not_received'
                                         ))
 AND DUC.GL_PRODUCT_GROUP = 467
 AND NVL(NET.Reversal_client_name,'x') NOT IN ('MerchantRefundService')
 AND duc.ship_method in ('DLV_GROUND_PANTRY', 'DLV_GROUND_PANTRY_COD')

    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
 ) a
 
LEFT JOIN PINDISTANCE  pd  
        ON a.Srcpin = pd.PINCODE_SRC    
        AND a.DSTPOST = pd.PINCODE_DST 
 
where damage_type <> 'Others'
group by 1,2,3,4,5,6,7,8,11,12)
;
 
 
create temporary table  district_pincode as
 (
 
 select distinct postal_code,district_name from STA_IN_CPU_INT_DDL.POSTAL_CODE_MAPPING  ) ;

 

SELECT final.ship_year,
       final.SHIP_MONTH,
       final.ship_Week,
       final.box,
       NULL AS dist,
        final.warehouse_id,
        final.damage_type,
        final.shipper_id,
        final.concession_value,
        final.TOTAL_UNITS_CONCEDED,
        final.DISTANCE_ZONE,
        final.DSTPOST,
        max(district_pincode.district_name) AS district
FROM FINAL
LEFT JOIN district_pincode ON FINAL.DSTPOST=district_pincode.postal_code
GROUP BY 1,
         2,
         3,
         4 ,
         6,
         7,
         8,
         9,
         10,
         11,
         12
