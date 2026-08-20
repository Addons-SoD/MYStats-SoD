local itemsets={
    {
        list={236133,236134,236135,236136,236137,236138,236139,236140,236141},
        bonus={
            [2]={
                stats={
                    expertise=2
                }
               
            }
        }
    },
    {
        list={236032,236033,236034,236035,236036,236037,236038,236039,236040},
        bonus={
            [2]={
                stats={
                    expertise=2
                }
               
            }
        }
    },
    {
        list={235201,236202,236203,236204,236205,236206,236207,236208,236209},
        bonus={
            [2]={
                stats={
                    expertise=2
                }
               
            }
        }
    },
    {
        list={236160,236169,236162,236163,236164,236165,236166,236167,236168},
        bonus={
            [2]={
                stats={
                    expertise=2
                }
               
            }
        }
    },
    {
        list={236005,236006,236007,236008,236009,236010,236011,236012,236013},
         bonus={
            [2]={
                stats={
                    expertise=2,
                   
                }
               
            },
        },

    },
    {
        list={236068,236069,236070,236071,236072,236073,236074,236075,236076},
         bonus={
            [2]={
                stats={
                    expertise=2
                }
               
            }
        },
    },
    {
        list={233418,233419,235012},
         bonus={
            [3]={
                stats={
                    expertise=5
                }
               
            }
        },
    }
}
ItemsetCollector={}
function ItemsetCollector:New() 
    local instance={
        stats={},
        itemCounts={},
        bonus={},
        bonusRecord={}
    }
    self.__index=self;
    setmetatable(instance,self)
    return instance;
end
local function indexOf(list,target)
    for i=1,#list do
        if list[i]==target then
            return i
        end
    end
    return 0
end
function ItemsetCollector:collectItemID(id)
    
    for i=1,#itemsets do
        if indexOf(itemsets[i].list,id) >0 then
         
            if not self.itemCounts[i] then
                self.itemCounts[i]=1
            else 
                self.itemCounts[i]=self.itemCounts[i]+1
            end
        
        end
    end
    for sid,v in pairs(self.itemCounts) do
      
        for n=2,6 do
            if v>=n and itemsets[sid].bonus[n] and (not self.bonusRecord[sid] or self.bonusRecord[sid]<n) then
                for k,v in pairs(itemsets[sid].bonus[n].stats) do
                    self.bonus[k]=(self.bonus[k] or 0)+itemsets[sid].bonus[n].stats[k]
                    
                end
                self.bonusRecord[sid]=n;
            end
        end
    end
end